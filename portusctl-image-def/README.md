# Building `portusctl` from source 


* Build and run : 
```bash
docker-compose down --rmi all && docker-compose up -d portusctl && docker-compose logs -f portusctl
```

* Wiping everything out : 
```bash 
docker-compose down --rmi all && docker system prune -f --all && docker-compose up -d portusctl && docker-compose logs -f portusctl
```
