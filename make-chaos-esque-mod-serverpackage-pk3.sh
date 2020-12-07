#git diff origin/master > xmod-chaos-esque-xonotic-binaries_1.serverpackage;
#git diff origin/master | grep Binary | cut -d " " -f 5- | cut -c 3- | cut -d " " -f 1 | zip -q xmod-chaos-esque-xonotic-binaries.pk3 -@ xmod-chaos-esque-xonotic-*.serverpackage;
#rm ./xmod-chaos-esque-xonotic-*.serverpackage;
#mv ./xmod-chaos-esque-xonotic-binaries.pk3 /var/www/xonoticmaps/

#echo "Did Binaries PK3"

git diff origin/master > xmod-chaos-esque-xonotic-edited_files.txt;
git diff --name-only origin/master | zip --symlinks -q zzzzzz999999_xmod-chaos-esque-xonotic-full_source_and_exec_binaries.pk3 -@ xmod-chaos-esque-xonotic-edited_files.txt;
zip --symlinks -r zzzzzz999999_xmod-chaos-esque-xonotic-full_source_and_exec_binaries.pk3 ./menu.* ./csprogs.* ./progs.* qcsrc GPL* COPYING;
rm ./xmod-chaos-esque-xonotic-edited_files.txt;
mv ./zzzzzz999999_xmod-chaos-esque-xonotic-full_source_and_exec_binaries.pk3 /var/www/xonoticmaps/

echo "Did Source Exes and Binaries PK3"

#zip -r aaaaaa000000_xmod-chaos-esque-xonotic-effectinfo_particlefont.pk3 ./effectinfo.txt ./particles/particlefont.tga;
#mv ./aaaaaa000000_xmod-chaos-esque-xonotic-effectinfo_particlefont.pk3 /var/www/xonoticmaps/

#echo "Did Effectinfo and Particlefont PK3"
