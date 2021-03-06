#!/bin/bash -e
#     ___ ___ _  _ ___ ___    _ _____ ___ ___         
#    / __| __| \| | __| _ \  /_\_   _| __|   \        
#   | (_ | _|| .` | _||   / / _ \| | | _|| |) |       
#    \___|___|_|\_|___|_|_\/_/_\_\_|_|___|___/_ _____ 
#   |   \ / _ \  | \| |/ _ \_   _| | __|   \_ _|_   _|
#   | |) | (_) | | .` | (_) || |   | _|| |) | |  | |  
#   |___/ \___/  |_|\_|\___/ |_|   |___|___/___| |_|  
# 



ctr_shared_dir=/var/lib/docker/volumes/shared
bastion_shared_dir=${ctr_shared_dir}/oso-bastion
bastion_configdata_dir=${bastion_shared_dir}/configdata
bastion_persistent_dir=${bastion_shared_dir}/persistent


# Create the directories that will be bound into the running container.
# In openshift these will be a ConfigMap and PersistentVolume respectively.
mkdir -p $bastion_configdata_dir
mkdir -p $bastion_persistent_dir/.ssh


# Necessary for sshd to work right
chmod 700 $bastion_persistent_dir/.ssh


# Populate authorized keys with this user's default rsa key
cp $HOME/.ssh/id_rsa.pub $bastion_persistent_dir/.ssh/authorized_keys
chmod 600 $bastion_persistent_dir/.ssh/authorized_keys


echo -n "Running oso-centos7-bastion... "

# TODO: Remove privileged, net=host and OO_PAUSE_ON_START
sudo docker run --rm=true -it --name oso-centos7-bastion    \
            --user $(id -u)                               \
            --privileged                                  \
            --net=host                                    \
            -v /var/lib/docker/volumes/shared:/shared:rw  \
            -v /var/lib/docker/volumes/shared/oso-bastion/configdata:/configdata:ro  \
            -v /var/lib/docker/volumes/shared/oso-bastion/persistent:/persistent:rw  \
            oso-centos7-bastion $@

echo "Done."
