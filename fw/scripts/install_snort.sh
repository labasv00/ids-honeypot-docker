export SNORT_INSTALL_DIR="/usr/local/"

mkdir $SNORT_INSTALL_DIR

apt-get install -y g++ cmake make gcc autoconf bison

# Instalamos SNORT

cd ~
mkdir tmp && cd tmp
export workdir=~/tmp

# Dependencias
# LibDAQ v3.0.12
cd $workdir
wget https://github.com/snort3/libdaq/archive/refs/tags/v3.0.12.tar.gz
tar xf v3.0.12.tar.gz 
cd libdaq-3.0.12
./bootstrap
./configure
make
make install

cd $workdir
wget https://github.com/ofalk/libdnet/archive/refs/tags/libdnet-1.17.0.tar.gz 
tar xf libdnet-1.17.0.tar.gz 
cd libdnet-libdnet-1.17.0
./configure
make
make install

cd $workdir
wget https://github.com/westes/flex/releases/download/v2.6.1/flex-2.6.1.tar.gz 
tar xf flex-2.6.1.tar.gz 
cd flex-2.6.1
./configure
make
make install

cd $workdir
wget https://download.open-mpi.org/release/hwloc/v2.9/hwloc-2.9.3.tar.gz 
tar xf hwloc-2.9.3.tar.gz 
cd hwloc-2.9.3
./configure
make
make install

cd $workdir
wget https://repo.or.cz/luajit-2.0.git/snapshot/e826d0c101d750fac8334d71e221c50d8dbe236c.tar.gz 
tar xf e826d0c101d750fac8334d71e221c50d8dbe236c.tar.gz 
cd luajit-2.0-e826d0c
make
make install

cd $workdir
echo "Downloading ZLIB"
wget https://www.zlib.net/zlib-1.3.tar.gz 
if [ ! -f "zlib-1.3.tar.gz" ];
then
    echo "Could not download ZLIB"
else
    echo "Configuring, compiling and installing ZLIB"
    tar xf zlib-1.3.tar.gz 
    cd zlib-1.3
    ./configure 
    if [ $? -ne 0 ]; then
        echo "Error configuring ZLIB"
    else
        make 
        if [ $? -ne 0 ]; then
            echo "Error compiling ZLIB"
        else 
            make install 
            if [ $? -ne 0 ]; then
                echo "Error installing ZLIB"
            else
                echo "Successfully installed ZLIB"
            fi
        fi
    fi
fi

cd $workdir
wget https://github.com/snort3/snort3/archive/refs/tags/3.1.73.0.tar.gz 
if [ ! -f "3.1.73.0.tar.gz" ];
then
    echo "Could not download SNORT"
else
    tar xf 3.1.73.0.tar.gz 
    cd snort3-3.1.73.0/

    
    ./configure_cmake.sh --prefix=$SNORT_INSTALL_DIR
    cd build
    make -j $(nproc)
    make install

fi

$SNORT_INSTALL_DIR/bin/snort --version

cd $workdir
wget https://www.snort.org/downloads/community/snort3-community-rules.tar.gz 
if [ ! -f "3.1.73.0.tar.gz" ];
then
    echo "Could not download Snort community rules"
else
    tar xf snort3-community-rules.tar.gz
    mkdir $SNORT_INSTALL_DIR/etc/rules
    mv snort3-community-rules $SNORT_INSTALL_DIR/etc/rules/community_rules

    # Por algún motivo diabólico, hay una serie de reglas de "asn1" que Snort no reconoce, da error, y no arranca
    # Parece ser un plugin (https://www.snort.org/faq/readme-asn1), sin embargo, parece que no se ha instalado correctamente: $(snort --list-plugins | grep asn)
    # No consigo arreglarlo instalando Snort Extra

    cd $SNORT_INSTALL_DIR/etc/rules/community_rules/
    # De modo que reitro las 10 líneas que dan error
    cat snort3-community.rules | head -n 1634 > fixed_rules.rules
    cat snort3-community.rules | tail -n 2412 | head -n 1267 >> fixed_rules.rules
    cat snort3-community.rules | tail -n 1143 >> fixed_rules.rules

    cd ..
    mkidr custom

fi

rm -Rf $workdir

# Desinstalar las dependencias
apt-get remove -y g++ cmake make gcc autoconf bison 
apt-get autoremove -y 