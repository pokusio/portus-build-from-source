# Building `portusctl` from source

You can change the target hardware for which protusctl is built, using the env. variables at

* Build and run :

```bash
docker-compose down --rmi all && docker-compose up -d portusctl && docker-compose logs -f portusctl

PORTUSCTL_CPU_ARCH=$(cat .env |grep GOLANG_CPU_ARCH|awk -F '=' '{print $2}')
PORTUSCTL_OS=$(cat .env |grep GOLANG_OS|awk -F '=' '{print $2}')

echo "And now you have portusctl executable, built for ${PORTUSCTL_OS} on ${PORTUSCTL_CPU_ARCH} CPU arch. available here : "

ls -all portusctl/portusctl

./portusctl/portusctl --version
./portusctl/portusctl --help


```

* Wiping everything out :
```bash
docker-compose down --rmi all && docker system prune -f --all && docker-compose up -d portusctl && docker-compose logs -f portusctl
```
