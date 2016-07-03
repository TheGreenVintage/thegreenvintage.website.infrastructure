submodules:
	git submodule init
	git submodule update

dev:
	ansible-playbook development.yml -i hosts --ask-sudo-pass -e 'ansible_python_interpreter=/usr/bin/python2.7' --ask-vault-pass

pro:
	ansible-playbook production.yml -i hosts --ask-sudo-pass -e 'ansible_python_interpreter=/usr/bin/python2.7'  --ask-vault-pass
