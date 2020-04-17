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
apt-get install sudo wget > /dev/null 2>&1 || true && \
apt-get -y dist-upgrade && \
locale-gen en_US.UTF-8 && \
update-locale LANG=en_US.UTF-8 && \
mkdir /home/ubuntu/ && \
bash -c '[[ -d /shared/gitian-builder ]] || git clone https://github.com/kleetus/gitian-builder /shared/gitian-builder' && \
chmod -R 775 /shared/gitian-builder/target-bin/
RUN if [[ $3 == *"osx"* ]]; then mkdir /shared/gitian-builder/inputs/ && \ wget https://bitcoincore.org/depends-sources/sdks/MacOSX10.14.sdk.tar.gz -O /shared/gitian-builder/inputs/MacOSX10.14.sdk.tar.gz;fi
USER root
RUN printf "[[ -d /shared/devault ]] || \
git clone https://github.com/devaultcrypto/devault /shared/devault && \
cd /shared/gitian-builder; \
./bin/gbuild --skip-image --commit devault=\$1 --url devault=\$2 \$3" > /root/runit.sh
CMD ["develop","https://github.com/devaultcrypto/devault.git","/shared/devault/contrib/gitian-descriptors/gitian-linux.yml"]
ENTRYPOINT ["sudo","bash", "/root/runit.sh"]
