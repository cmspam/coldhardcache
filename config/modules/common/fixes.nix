# Temporary workarounds for upstream bugs. Each entry should have a comment
# explaining what/why and a link so it's obvious when the fix can be deleted.
{ ... }:
{
  nixpkgs.overlays = [
    (_: prev: {
      openldap = prev.openldap.overrideAttrs {
        doCheck = !prev.stdenv.hostPlatform.isi686;
      };
    })
  ];

}
