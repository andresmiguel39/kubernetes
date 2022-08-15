 docker run --rm -dti -v d:/Workspace/kubernetes/app/front/src:/go --net host --name golang golang bash

 docker rm -fv 8602fb7187492182cc8b234975fba13a6f27459a3426de1aab1fdf0b76b47215

docker exec -it 8602fb7187492182cc8b234975fba13a6f27459a3426de1aab1fdf0b76b47215 sh






package main

import (
	"encoding/json"
	"net/http"
	"os"
	"time"
)

type HandsOn struct {
	Time 		time.Time 	`json:"time"`
	Hostname 	string		`json:"hostname"`
}

func ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r )
		return
	}

	resp := HandsOn{
		Time:		time.Now(),
		Hostname:	os.Getenv("HOSTNAME"),
	}

	jsonResp, err := json.Marshal(&resp)
	if err != nil {
		w.Write([]byte("Error"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Write(jsonResp)

}
func main() {
	http.HandleFunc("/", ServeHTTP)
	http.ListenAndServe(":8081", nil)
}




FROM golang:1.13 as builder

WORKDIR /app
COPY main.go .
RUN CGO_ENABLED=0 GOOS=linux GOPROXY=https://proxy.golang.org go build -o app ./main.go

FROM alpine:latest 

WORKDIR /app
COPY --from=builder /app/app .
CMD ["./app"]





docker build -f ./Dockerfile -t k8sapp/k8sapp d:/Workspace/kubernetes/app/backend

docker run -d -p 8082:8081 --name k8sapp/k8sapp k8sapp 

netstat -an | grep 'LISTEN'

imagePullPolicy: IfNotPresent


 Failed to pull image "k8sapp": rpc error: code = Unknown desc = Error response from daemon: pull access denied for k8sapp, repository does not exist or may require 'docker login': denied: requested access to the resource is denied


 kubectl exec --stdin --tty frontend-559dd49d59-njdpv -- sh
 
 kubecto run other --image=nginx

 apk add -U lynx

minikube docker-env

minikube start

minikube -p minikube docker-env

eval $(minikube -p minikube docker-env)

docker build . -f Dockerfile -t andresmiguel/k8sappfront:1.0

kubectl port-forward service/backend-k8sapp 80:80

kubectl port-forward other 80:80



<div id="id01"></div>
<script>
var xmlhttp = new XMLHttpRequest();
var url = "http://backend-k8sapp";

xmlhttp.onreadystatechange = function() {
	if (this.readyState == 4 && this.status == 200) {
		var resp = JSON.parse(this.responseText);
		document.getElementById("id01").innerHTML = "<h2>Hora: " + resp.time + " Server: " + resp.hostname + "</h2>";
	}	
};

xmlhttp.open("GET", url, true);
xmlhttp.send();

</script>






<div id="id01"></div>

<script>
var xmlhttp = new XMLHttpRequest();
var url = "http://backend-k8sapp";

xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
        var resp = JSON.parse(this.responseText);
        document.getElementById("id01").innerHTML = "<h2>Hora: " + resp.time + " Server: " + resp.hostname + "</h2>";
    }
};
xmlhttp.open("GET", url, true);
xmlhttp.send();

</script>


