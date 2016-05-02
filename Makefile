submodules:
	git submodule init
	git submodule update

development:
	ansible-playbook development.yml -i hosts --ask-sudo-pass
