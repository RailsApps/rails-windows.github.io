echo "publishing to the rails-windows.github.io site"
cd ~/workspace/rails-windows/rails-windows.github.io.wiki
gollum-site generate
echo "GENERATED";
cp -R _site/* ../rails-windows.github.io
rm -rf _site/
cd ../rails-windows.github.io
mv Home.html index.html
echo "COMMITTING";
git add -A
git commit -am "update website"
git push origin master
echo "FINISHED";
exit 0
