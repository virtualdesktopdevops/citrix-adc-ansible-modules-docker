# citrix-adc-ansible-modules-docker
Docker image embedding Citrix ADC &amp; ADM Ansible collections

## Usage
1. Create an Ansible inventory file with the Citrix ADC `nsip`, `nitro_user`, `nitro_password` parameters :

```
[citrix_adc]
172.25.249.241 nsip=172.25.249.241:9443 nitro_user=nsroot nitro_pass=nsroot validate_certs=no
```

2. Create an Ansible playbook enbedding Citrix ADC configurations. Samples and documentation are provided on https://github.com/citrix/citrix-adc-ansible-modules :

```
---

- hosts: citrix_adc
  gather_facts: false
  collections:
    - citrix.adc

  tasks:
    - name: lb vserver
      delegate_to: localhost
      citrix_adc_lb_vserver:
        nsip: "{{ nsip }}"
        nitro_user: "{{ nitro_user }}"
        nitro_pass: "{{ nitro_pass }}"
        validate_certs: no


        name: lb-vserver-1
        servicetype: HTTP
        ipv46: 6.92.2.2
        port: 80

    - name: cs action
      delegate_to: localhost
      citrix_adc_cs_action:
        nsip: "{{ nsip }}"
        nitro_user: "{{ nitro_user }}"
        nitro_pass: "{{ nitro_pass }}"
        validate_certs: no

        name: action1
        targetlbvserver: lb-vserver-1
```

3. Run ansible-playbook using **citrix-adc-ansible-modules** docker image to deploy configuration :

```
docker run --rm -v $(pwd):/pwd citrix-adc-ansible-modules:latest ansible-playbook -i inventory.txt samples/cs_action.yaml
```