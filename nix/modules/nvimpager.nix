{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      # nvimpager only understands semicolon-separated SGR parameters, so the
      # colon form from ITU-T T.416 -- which systemd emits, e.g.
      # \e[0;38:5:245m -- is neither concealed nor colored and shows up as
      # literal garbage in journalctl output. Still broken on upstream master;
      # the closest report is lucc/nvimpager#79, which never mentions colons.
      #
      # Widen the two patterns that recognize SGR sequences, then normalize
      # colons to semicolons before parsing (dropping the empty colorspace
      # field in the 38:2::R:G:B form) so the tokenizer works unchanged.
      nvimpager = prev.nvimpager.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace lua/nvimpager/ansi2highlight.lua \
            --replace-fail '\\e\\[[0-9;]' '\\e\\[[0-9;:]' \
            --replace-fail '"\27%[([0-9;]*)m"' '"\27%[([0-9;:]*)m"' \
            --replace-fail 'state:parse(spec)' 'state:parse((spec:gsub(":", ";"):gsub("([34]8;2);;", "%1;")))'
        '';
      });
    })
  ];
}
