## instructions from https://www.nextflow.io/docs/latest/awscloud.html

## ---- set line endings
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

WD="/home/ec2-user/"

###############################################################
## AWS: UPDATE & CONFIGURE
###############################################################

sudo yum install deltarpm -y -q
sudo yum update -y -q
sudo yum-complete-transaction --cleanup-only -q
sudo yum groupinstall "Development tools" -y -q
sudo yum install zlib-devel ncurses-devel cmake patch tmux htop python-pip -y -q

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install


###############################################################
## conda
###############################################################

cd ${WD}
wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p ${WD}/miniconda3
export PATH="${WD}/miniconda3/condabin:$PATH"
export PATH="${WD}/miniconda3/bin:$PATH"
