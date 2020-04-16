FROM ubuntu:bionic
MAINTAINER Chris Kleeschulte <chrisk@bitpay.com>
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /shared
RUN apt-get update && \
apt-get --no-install-recommends -yq install \
locales \
git-core \
build-essential \
ca-certificates \
ruby \
rsync && \
apt-get -yq purge grub > /dev/null 2>&1 || true && \
apt-get install sudo > /dev/null 2>&1 || true && \
apt-get -y dist-upgrade && \
locale-gen en_US.UTF-8 && \
update-locale LANG=en_US.UTF-8 && \
bash -c '[[ -d /shared/gitian-builder ]] || git clone https://github.com/kleetus/gitian-builder /shared/gitian-builder' && \
useradd -d /home/root -m -s /bin/bash root && \
chown -R root.root /shared/ && \
chown root.root /shared/gitian-builder/target-bin/grab-packages.sh && \
chmod 755 /shared/gitian-builder/target-bin/grab-packages.sh && \
echo 'root ALL=(root) NOPASSWD:/usr/bin/apt-get,/shared/gitian-builder/target-bin/grab-packages.sh' > /etc/sudoers.d/root && \
chown root.root /etc/sudoers.d/root && \
chmod 0400 /etc/sudoers.d/root && \
chown -R root.root /home/root

USER root
RUN printf "[[ -d /shared/devault ]] || \
git clone https://github.com/devaultcrypto/devault /shared/devault && \
cd /shared/gitian-builder; \
./bin/gbuild --skip-image --commit devault=\$1 --url devault=\$2 \$3" > /home/root/runit.sh
CMD ["develop","https://github.com/devaultcrypto/devault.git","/shared/devault/contrib/gitian-descriptors/gitian-linux.yml"]
ENTRYPOINT ["sudo","bash", "/home/root/runit.sh"]
