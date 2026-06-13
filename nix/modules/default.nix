{ lib, ... }: {
  import = lib.filesystem.listFilesRecursive ./.;
}
