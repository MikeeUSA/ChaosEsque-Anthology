git diff origin/master | grep Binary | cut -d " " -f 5- | cut -c 3- | cut -d " " -f 1 | zip -q diff-xonotic-mod-binaries.pk3 -@
