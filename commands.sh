#!/bin/bash

generate_ca_keys(){
	#generate private key
	openssl genrsa -passout pass:foobar -aes256 -out ./ca/ca-key.pem 4096
	#generate public key
	openssl req -new -x509 -passin pass:foobar -days 365 -key ./ca/ca-key.pem -sha256 -out ./ca/ca.pem
}

generate_client_certificate(){
	#generate private key
	openssl genrsa -out ./client/key.pem 4096
	#generate public key
	openssl req -subj '/CN=client' -new -key ./client/key.pem -out ./client/client.csr
	#generate a signed certificate
	echo extendedKeyUsage = clientAuth > ./client/extfile-client.cnf
	openssl x509 -req -days 365 -sha256 -in ./client/client.csr -CA ./ca/ca.pem -CAkey ./ca/ca-key.pem -CAcreateserial -out ./client/cert.pem -extfile ./client/extfile-client.cnf -passin pass:foobar
}

configure_slaves(){
	echo "subjectAltName = DNS:$(hostname -I | awk '{print $2}'),IP:<HOST_IP>" > ./server/template.cnf
	echo "extendedKeyUsage = serverAuth" >> ./server/template.cnf
	ansible-playbook slaves_playbook.yml
}
replace(){
	sed s/'<HOST_IP>'/$(hostname -I | awk '{print $2}')/g /server/template.cnf >> /server/extfile.cnf
}

#function called by the playbook in each slaves
generate_server_certificate(){
	#configure extfile.cnf
	replace
	#generate private key
	openssl genrsa -out /server/server-key.pem 4096
	#generate the certificate
	openssl req -subj "/CN=$(hostname -I | awk '{print $2}')" -sha256 -new -key /server/server-key.pem -out /server/server.csr
	#generate the signed certificate
	openssl x509 -req -days 365 -sha256 -in /server/server.csr -CA /ca/ca.pem -CAkey /ca/ca-key.pem -CAcreateserial -out /server/server-cert.pem -extfile /server/extfile.cnf -passin pass:foobar
}


clean_files(){
	rm /server/server.csr 
	rm /server/extfile.cnf
	rm /ca/*

}


delete_all(){
	rm ./ca/*
	rm ./server/*
	rm ./client/*
}

case $1 in
	"ca")
	generate_ca_keys;;
	"client")
	generate_client_certificate;;
	"slaves")
	configure_slaves;;
	"server")
	generate_server_certificate;;
	"clean")
	clean_files;;
	"replace")
	replace;;
	"delete")
	delete_all;;
esac
