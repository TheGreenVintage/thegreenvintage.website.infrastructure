container = thegreenvintage

submodules:
	git submodule init
	git submodule update

container:
	sudo lxc-create -t download -n $(container)
	sudo lxc-start -n $(container)
	echo "Container created! Add a reference in /etc/hosts"

remotes:
	echo "Adding static local remote..."
	cd ../static; \
		git remote get-url local > /dev/null && git remote remove local; \
		git remote add local "$(container)@local.$(container).com:shared/repositories/static";
	echo "Adding static deploy remote..."
	cd ../static; \
		git remote get-url deploy > /dev/null && git remote remove deploy; \
		git remote add deploy "$(container)@$(container).com:shared/repositories/static"
	echo "Adding dynamic local remote..."
	cd ../dynamic; \
		git remote get-url local > /dev/null && git remote remove local; \
		git remote add local "$(container)@local.$(container).com:shared/repositories/dynamic"
	echo "Adding dynamic deploy remote..."
	cd ../dynamic; \
		git remote get-url deploy > /dev/null && git remote remove deploy; \
		git remote add deploy "$(container)@$(container).com:shared/repositories/dynamic"

setup:
	sudo lxc-create -n $(container) -t download -- --dist ubuntu --release xenial --arch amd64
	sudo lxc-start  -n $(container)
	sudo lxc-wait   -n $(container) -s RUNNING
	sleep 10 # Waiting for ip address
	sudo lxc-attach -n $(container) -- apt -y install openssh-server python2.7
	sudo lxc-attach -n $(container) -- usermod -l $(container) -m -d /home/$(container) ubuntu
	sudo lxc-attach -n $(container) -- groupmod -n $(container) ubuntu
	sudo lxc-attach -n $(container) -- passwd $(container)
	sudo sed -i '/local.$(container).com/d' /etc/hosts
	echo `sudo lxc-info -n $(container) | grep IP | awk '{ print $$2 }'` local.$(container).com next.local.$(container).com | sudo tee -a /etc/hosts
	ssh-keygen -f ~/.ssh/known_hosts -R local.$(container).com
	ssh-copy-id -i ~/.ssh/id_rsa.pub $(container)@local.$(container).com

provision:
	@read -p "Enter IP address: " IP; \
	ansible-playbook provision.yml -i hosts -e ansible_host=$$IP -e 'ansible_user=root'

dev:
	ansible-playbook development.yml -i hosts --ask-sudo-pass -e ansible_user=$(container) -e 'ansible_python_interpreter=/usr/bin/python2.7' --ask-vault-pass

pro:
	ansible-playbook production.yml -i hosts --ask-sudo-pass -e ansible_user=$(container) -e 'ansible_python_interpreter=/usr/bin/python2.7'  --ask-vault-pass

i_feel_lucky: submodules setup dev
