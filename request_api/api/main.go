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


func GetRequest(requestID int) (request request, err error) {
    tx, err := db.Begin()
    if err != nil {
        glog.Error(err)
        return request, err
    } else {
        glog.Info("ERROR ON BEGIN IS NiLL!!!")
    }

    rows, err := tx.Query(`SELECT id, table_id, menu_item_id, place_id FROM requests WHERE id = $1`, requestID)
    if err != nil {
        glog.Error(err)
        tx.Rollback()
        return request, err
    }
    defer rows.Close()

    for rows.Next() {
        err = rows.Scan(&request.ID, &request.TableID, &request.MenuItemID, &request.PlaceID)
        if err != nil {
            tx.Rollback()
            return request, err
        }
    }

    if request.ID == 0 {
        glog.Info("Non existing row!")
        return request, errors.New(`missing_row`)
    }

    tx.Commit()
    return request, err
}

func GetPlaceAndTable(tableID string) (table table, err error) {
    tx, err := db.Begin()
    if err != nil {
        glog.Error(err)
        return table, err
    } else {
        glog.Info("transaction opened")
    }

    rows, err := tx.Query(`SELECT p.preferences_json, t.id, t.id_hash mi.id, mi.name, mi.ordering
                        FROM tables t join places p ON t.place_id = p.id
                        LEFT JOIN menu_items mi ON t.place_id = mi.place_id WHERE t.id_hash = $1;`, tableID)
    if err != nil {
        glog.Error(err)
        tx.Rollback()
        return table, err
    }

    var items []menuItem
    for rows.Next() {
        var item menuItem
        err = rows.Scan(&table.PreferencesJSON, &table.ID, &table.IDHash, &item.ID, &item.Name, &item.Ordering)
        if err != nil {
            tx.Rollback()
            return table, err
        }
        items = append(items, item)
    }
    table.MenuItems = items

    defer rows.Close()
    return table, err
}

var db *sql.DB //This is a connection pool. It must be global so it is visible in all files

/*
Must be called in the main function. It will create the nessecary environment for the storage.
*/
func InitStorage() {
    var err error

    glog.Info("Testing the db!")
    //var tx    *sql.Tx
    db, err = sql.Open(os.Getenv("DB_CONNECTION_DRIVER"), os.Getenv("DB_CONNECTION_STRING"))
    if err != nil {
        glog.Error(err)
    }
    if db == nil {
        glog.Fatal(db)
    }
    glog.Info("Db conn is ok!")
}

func WriteResp(w http.ResponseWriter, status int, msg string) {
    http.Error(w, msg, status)
}
