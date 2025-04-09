#!bash

# Install zipperposition
printf "\n" | bash -c "sh <(cat /home/lean_hammertest_lw/install_opam.sh)"
echo "set timeout -1
spawn opam init
expect {
    \"Sandboxing is not working\"      {send "y"; exp_continue}
    \"Do you want opam to configure\"  {send "5"}
}
expect eof
" | expect
opam switch create zipperpn 4.14.0
opam switch zipperpn
eval $(opam env)
echo "set timeout -1
spawn opam install zipperposition
expect \"Proceed with\"
send "y"
expect eof
" | expect
echo "set timeout -1
spawn opam pin -k git https://github.com/sneeuwballen/zipperposition.git#050072e01d8539f9126993482b595e09f921f66a
expect \"This will pin the following packages\"
send "y"
expect \"Proceed with\"
send "y"
expect eof
" | expect