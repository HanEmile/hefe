function pmk() {
	docker run \
		-v \
		"$(pwd):/pwn" \
		--cap-add=SYS_PTRACE \
		--security-opt seccomp=unconfined \
		-d \
		--name $1 \
		-i \ 
		ctf_ubuntu22.10;
}

function pcd() {
	docker exec \
		-it \
		--workdir /pwn \
		$1 \
		bash;
}

function prm() {
	docker stop $1;
}

function pls() {
	docker ps \
		-a \
		-f ancestor=ctf_ubuntu22.10 \
		--format "{{.Names}}";
}
