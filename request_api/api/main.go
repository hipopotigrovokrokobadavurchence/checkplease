package main

import (
    "database/sql"
    "encoding/json"
    "errors"
    "expvar"
    "flag"
    "io/ioutil"
    "net/http"
    "os"

    "github.com/golang/glog"
    "github.com/gorilla/mux"
    _ "github.com/lib/pq"
)

var (
    statistics = expvar.NewMap("reqCounters")
)

func main() {
    InitStorage()
    flag.Parse()
    glog.Info("hello world!")
    statistics.Add(`addUserHashReqCount`, 0)
    router := mux.NewRouter().StrictSlash(false)
    router.HandleFunc("/api/", JSONHandler)
    glog.Info("Starting server on: ", os.Getenv("API_PORT"), " and endpoint: /api/")
    glog.Info(http.ListenAndServe(":"+os.Getenv("API_PORT"), router))
}

func JSONHandler(w http.ResponseWriter, r *http.Request) {
}
