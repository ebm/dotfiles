{ pkgs, ... }:

# Hardlinks a finished download into the Jellyfin library. A hardlink is the
# same inode under a second name, so this costs no space, leaves the torrent
# seeding from the original path, and keeps the file once that torrent goes.
#
# Two preconditions, both true today and both easy to break later:
#
#   * downloads/, shows/ and movies/ are one filesystem -- `ln` across
#     filesystems fails outright, so a separate mount for downloads would
#     break this rather than silently copying.
#
#   * fs.protected_hardlinks is 1 (the kernel default), so linking a file you
#     do not own needs read *and* write on it. Completed downloads are 0664
#     transmission:media thanks to `umask = 2` in transmission.nix, and ethan
#     is in the media group. Tightening that umask breaks this with an
#     opaque EPERM.
#
# Deliberately does no renaming: Jellyfin strips release cruft from folder
# names and reads season/episode numbers out of filenames itself.
#
# shows vs movies is guessed unless given. An SxxExx or 1x01 tag settles it
# for scene TV; anime batches carry neither, so a folder holding more than
# one video file counts as a season too. That leaves a single anime episode
# looking exactly like a movie -- pass the argument for those.

{
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "medialink";
      runtimeInputs = with pkgs; [
        coreutils
        findutils
        gnugrep
      ];
      text = ''
        # medialink [<source> [shows|movies]]
        #
        # With no arguments, sweeps every completed download. Transmission
        # holds unfinished torrents in incomplete/, so anything sitting in
        # downloads/ is done and safe to link.

        downloads=/srv/media/downloads
        video='.*\.(mkv|mp4|avi|m4v|mov|webm)'

        link() {
          local src=''${1%/} kind=''${2:-} names dest n f

          [ -d "$src" ] || { echo "medialink: no such folder: $src" >&2; return 1; }

          names=$(find "$src" -type f -regextype posix-extended -iregex "$video" -printf '%f\n')
          [ -n "$names" ] || return 0

          if [ -z "$kind" ]; then
            if grep -qiE 's[0-9]{1,2}[ ._-]*e[0-9]{1,3}|[0-9]{1,2}x[0-9]{2}' <<<"$names"; then
              kind=shows
            elif [ "$(grep -c . <<<"$names")" -gt 1 ]; then
              kind=shows
            else
              kind=movies
            fi
          fi

          case "$kind" in
            shows | movies) ;;
            *) echo "medialink: expected 'shows' or 'movies', got '$kind'" >&2; return 2 ;;
          esac

          dest=/srv/media/$kind/''${src##*/}
          mkdir -p "$dest"

          # Skips what is already linked, so a sweep only picks up what is new
          # and re-running against a growing folder is safe. Reads from a
          # process substitution rather than a pipe so the count survives.
          n=0
          while IFS= read -r -d "" f; do
            [ -e "$dest/''${f##*/}" ] && continue
            ln "$f" "$dest/"
            n=$((n + 1))
          done < <(find "$src" -type f -regextype posix-extended -iregex "$video" -print0)

          # Silent when there was nothing new, so a sweep only reports changes.
          if [ "$n" -gt 0 ]; then
            echo "medialink: $n -> $dest"
          fi
        }

        if [ $# -eq 0 ]; then
          for d in "$downloads"/*/; do
            [ -d "$d" ] && link "$d"
          done
        else
          link "$@"
        fi
      '';
    })
  ];
}
