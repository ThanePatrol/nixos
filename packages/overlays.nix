final: prev: {
  opendrop = prev.opendrop.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      final.openssl      
      final.fleep
      final.libarchive-c
      final.pillow
      final.requests-toolbelt
      final.setuptools
      final.zeroconf
    ];
  });
}
