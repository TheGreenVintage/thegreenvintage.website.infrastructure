submodules:
	git submodule init
	git submodule update

development:
	ansible-playbook development.yml -i hosts --ask-sudo-pass

production:
	ansible-playbook production.yml -i hosts --ask-sudo-pass
