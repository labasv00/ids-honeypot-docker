#!/bin/bash
echo "Installing Cowrie"
useradd -m cowrie
cd /home/cowrie

wget https://github.com/cowrie/cowrie/archive/refs/tags/v2.5.0.tar.gz
tar xf v2.5.0.tar.gz

rm v2.5.0.tar.gz
ln -s cowrie-2.5.0/ cowrie

cd cowrie/etc
cp cowrie.cfg{.dist,}
cp userdb{.example,.txt}
sed "s@hostname = svr04@hostname = leon@g" -i cowrie.cfg
echo "leon:x:leon" >> userdb.txt

cd ..
python3 -m venv cowrie-env
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade -r requirements.txt

cd /home/cowrie/
cp /root/scripts/start_cowrie.sh .
chmod +x start_cowrie.sh

chown cowrie.cowrie -R .
