FROM alpine:3.10 as builder

ENV ANSIBLE_VERSION=2.9.2

# Install Python3 and Ansible
RUN set -xe \
    && echo "****** Install system dependencies ******" \
        && apk add --no-cache --progress python3 openssl ca-certificates git openssh sshpass \
	    && apk --update add --virtual build-dependencies python3-dev libffi-dev openssl-dev build-base \
	&& echo "****** Install ansible and python dependencies ******" \
        && pip3 install --upgrade pip \
	    && pip3 install ansible==${ANSIBLE_VERSION} \
    && echo "****** Remove unused system librabies ******" \
	    && apk del build-dependencies \
	    && rm -rf /var/cache/apk/*

# Install Citrix ADC Ansible modules
COPY citrix-adc-ansible-modules /tmp/citrix-adc-ansible-modules

RUN cd /tmp/citrix-adc-ansible-modules \
    && pip3 install deps/nitro-python-1.0_kamet.tar.gz \
    && cd ansible-collections/adc \
    && ansible-galaxy collection build \
    && ansible-galaxy collection install citrix-adc-1.0.0.tar.gz \
    && rm -rf /tmp/citrix-adc-ansible-modules \
    && mkdir /pwd



FROM alpine:3.10
LABEL maintainer="32440697+matt6697@users.noreply.github.com"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="virtualdesktopdevops/citrix-adc-ansible-modules"
LABEL org.label-schema.description="Docker image embedding Citrix ADC &amp; ADM Ansible collections"
LABEL org.label-schema.vcs-url="https://github.com/virtualdesktopdevops/citrix-adc-ansible-modules-docker"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="virtualdesktopdevops"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker run --rm -v $(pwd):/pwd citrix-adc-ansible-modules:slim ansible-playbook -i inventory.txt samples/cs_action.yaml"

RUN set -eux \
	&& apk add --no-cache python3 \
	&& ln -sf /usr/bin/python3 /usr/bin/python \
	&& ln -sf ansible /usr/bin/ansible-config \
	&& ln -sf ansible /usr/bin/ansible-console \
	&& ln -sf ansible /usr/bin/ansible-doc \
	&& ln -sf ansible /usr/bin/ansible-galaxy \
	&& ln -sf ansible /usr/bin/ansible-inventory \
	&& ln -sf ansible /usr/bin/ansible-playbook \
	&& ln -sf ansible /usr/bin/ansible-pull \
	&& ln -sf ansible /usr/bin/ansible-test \
	&& ln -sf ansible /usr/bin/ansible-vault \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf \
    && mkdir /pwd

COPY --from=builder /usr/lib/python3.7/site-packages/ /usr/lib/python3.7/site-packages/
COPY --from=builder /usr/bin/ansible /usr/bin/ansible
COPY --from=builder /usr/bin/ansible-connection /usr/bin/ansible-connection
COPY --from=builder /root/.ansible/collections /root/.ansible/collections

WORKDIR /pwd

CMD ["ansible-playbook", "--version"]
