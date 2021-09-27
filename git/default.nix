{ git, symlinkJoin, makeWrapper }:

git.overrideAttrs (
  old: rec {
    configureFlags = [ "--with-gitconfig=$out/etc/gitconfig" ];
    postInstall = old.postInstall + ''
      cat << EOF | tee $out/etc/gitconfig
        [user]
          name = Matthew Murray
          email = mattmurr.uk@gmail.com
          signingkey = C887ABBA2A2B1837A1DF243D3B11FE4ADE028D64
        [commit]
          gpgsign = true
      EOF
    '';
  }
)
