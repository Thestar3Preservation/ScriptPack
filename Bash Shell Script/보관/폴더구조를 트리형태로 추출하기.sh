#!/home/user/Home/.usersys/bashscriptrecode
IFS=$'\n'
tree -ad -H . > temp.html
tf=$(w3m -cols 98304 -dump temp.html)
echo "$tf" | sed -e "$(($(echo "$tf" | wc -l)-6)),\$d" | tee -a Tree.txt
rm temp.html
exit
