package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"expvar"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"

	"github.com/golang/glog"
	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
)

var (
	statistics = expvar.NewMap("counters")
	statItems  = expvar.NewMap("statItems")
)

func main() {
	InitStorage()

	//statistics

	flag.Parse()
	glog.Info("hello world!")
	//statistics.Add(`Total acknowedged requests:`, 1)
	//statistics.Add(`Total requests: `, 1)
	statistics.Add("Devin 500ml", 60)
	statistics.Add("Hapy Hour Rum", 120)
	statistics.Add("Coke", 700)
	statistics.Add("Happy Hour Chips", 27)
	statistics.Add("Capt Morgan", 15)
	statistics.Add("Old Fashioned", 35)

	router := mux.NewRouter().StrictSlash(false)
	router.HandleFunc("/api/", JSONHandler)
	router.HandleFunc("/statistics/", expvarHandler)
	glog.Info("Starting server on: ", os.Getenv("API_PORT"), " and endpoint: /api/")
	glog.Info(http.ListenAndServe(":"+os.Getenv("API_PORT"), router))
}

func JSONHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	if r.Method != "POST" {
		WriteResp(w, http.StatusMethodNotAllowed,
			`{"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error!"}, "id": "1"}`)
		glog.Error(r.Method)
		return
	}

	bytes, err := ioutil.ReadAll(r.Body)
	if err != nil {
		WriteResp(w, http.StatusInternalServerError,
			`{"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error!"}, "id": "1"}`)
		return
	}

	var apiReq JsonRPCReq
	err = json.Unmarshal(bytes, &apiReq)
	if err != nil {
		glog.Error("Json parse error: ", err)
		WriteResp(w, http.StatusInternalServerError,
			`{"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error!"}, "id": "1"}`)
		return
	}

	glog.Info(`!!!!!!!!apiRequest: `, apiReq)
	if apiReq.Method == `GetPlaceAndTable` {
		table, err := GetPlaceAndTable(apiReq.Params["tableID"])
		if err != nil {
			glog.Info("JSON marshal error: ", err.Error())
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32603, "message": "Internal error!"}, "id": "1"}`)
			return
		}
		bytes, err = json.Marshal(table)
		if err != nil {
			glog.Info("JSON marshal error: ", err.Error())
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32603, "message": "Internal error!"}, "id": "1"}`)
			return
		}
	} else if apiReq.Method == `GetPendingRequests` {

		placeID, err := strconv.Atoi(apiReq.Params["placeID"])
		if err != nil {
			glog.Info("placeID is not an integer: ", apiReq.Params["placeID"])
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32602, "message": "Invalid method parameter(s)."}, "id": "1"}`)
			return
		}
		requests, err := GetPendingRequests(placeID)

		if err != nil && err.Error() == `missing_row` {
			glog.Info("GetPendingRequests error: ", err.Error())
			WriteResp(w, http.StatusOK,
				`{"jsonrpc": "2.0", "error": {"code": -32603, "message": "Non existant row!"}, "id": "1"}`)
			return
		}

		if err != nil {
			glog.Info("GetPendingRequests error: ", err.Error())
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32603, "message": "Internal error!"}, "id": "1"}`)
			return
		}

		bytes, err = json.Marshal(requests)
		if err != nil {
			glog.Info("JSON marshal error: ", err.Error())
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32603, "message": "Internal error!"}, "id": "1"}`)
			return
		}
	} else if apiReq.Method == `GetRequest` {
		requestID, err := strconv.Atoi(apiReq.Params["requestID"])
		if err != nil {
			glog.Info("placeID is not an integer: ", apiReq.Params["requestID"])
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32602, "message": "Invalid method parameter(s)."}, "id": "1"}`)
			return
		}
		request, err := GetRequest(requestID)
		if err != nil && err.Error() == `missing_row` {
			glog.Info("GetPendingRequests error: ", err.Error())
			WriteResp(w, http.StatusOK,
				`{"jsonrpc": "2.0", "error": {"code": -32603, "message": "Non existant row!"}, "id": "1"}`)
			return
		}

		if err != nil {
			glog.Info("Error: ", err.Error())
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32603, "message": "Internal error!"}, "id": "1"}`)
			return
		}

		bytes, err = json.Marshal(request)
		if err != nil {
			glog.Info("JSON marshal error: ", err.Error())
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32603, "message": "Internal error!"}, "id": "1"}`)
			return
		}
	} else if apiReq.Method == `AddRequest` {
		tableID, err := strconv.Atoi(apiReq.Params["tableID"])
		if err != nil {
			glog.Info("tableID is not an integer: ", apiReq.Params["tableID"])
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32602, "message": "Invalid method parameter(s)."}, "id": "1"}`)
			return
		}

		menuItemID, err := strconv.Atoi(apiReq.Params["menuItemID"])
		if err != nil {
			glog.Info("menuItemID is not an integer: ", apiReq.Params["menuItemID"])
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32602, "message": "Invalid method parameter(s)."}, "id": "1"}`)
			return
		}

		placeID, err := strconv.Atoi(apiReq.Params["placeID"])
		if err != nil {
			glog.Info("placeID is not an integer: ", apiReq.Params["placeID"])
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32602, "message": "Invalid method parameter(s)."}, "id": "1"}`)
			return
		}

		request, err := AddRequest(tableID, menuItemID, placeID)

		if err != nil {
			glog.Info("AddRequest error: ", err.Error())
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32603, "message": "Internal error!"}, "id": "1"}`)
			return
		}

		bytes, err = json.Marshal(request)
		if err != nil {
			glog.Info("JSON marshal error: ", err.Error())
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32603, "message": "Internal error!"}, "id": "1"}`)
			return
		}

	} else if apiReq.Method == `AckRequest` {
		requestID, err := strconv.Atoi(apiReq.Params["requestID"])
		if err != nil {
			glog.Info("placeID is not an integer: ", apiReq.Params["requestID"])
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32602, "message": "Invalid method parameter(s)."}, "id": "1"}`)
			return
		}
		_, err = AckRequest(requestID)
		if err != nil {
			glog.Info("Error: ", err.Error())
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32603, "message": "Internal error!"}, "id": "1"}`)
			return
		}

		bytes, err = json.Marshal("asd")
		if err != nil {
			glog.Info("JSON marshal error: ", err.Error())
			WriteResp(w, http.StatusInternalServerError,
				`{"jsonrpc": "2.0", "error": {"code": -32603, "message": "Internal error!"}, "id": "1"}`)
			return
		}
	} else {
		WriteResp(w, http.StatusInternalServerError,
			`{"jsonrpc": "2.0", "error": {"code": -32601, "message": "The method does not exist / is not available."}, "id": "1"}`)
		return
	}

	WriteResp(w, http.StatusOK, string(bytes))
}

func AddRequest(tableID int, menuItemID int, placeID int) (request request, err error) {
	err = db.QueryRow("INSERT INTO  requests(table_id, menu_item_id, place_id, inserted_by, updated_by, state_id) VALUES($1, $2, $3, $4, $5, $6) Returning ID ;",
		tableID, menuItemID, placeID, 1, 1, 10).Scan(&request.ID)
	tx, err := db.Begin()
	if err != nil {
		glog.Error(err)
		return request, err
	}
	rows, err := tx.Query(`SELECT name from menu_items where id = $1`, menuItemID)
	if err != nil {
		glog.Error(err)
		tx.Rollback()
		return request, err
	}
	defer rows.Close()

	var menuItemName string
	for rows.Next() {
		err = rows.Scan(&menuItemName)
		if err != nil {
			tx.Rollback()
			return request, err
		}
	}
	statistics.Add(menuItemName, 1)
	if err != nil {
		glog.Error("INSERT FAILED")
		return request, err
	}

	return request, err
}

func AckRequest(requestID int) (string, error) {
	err := db.QueryRow("UPDATE requests set state_id = 50  where ID = $1", requestID).Scan()
	if err != nil {
		glog.Info("AAAA: ", err)
	}

	statistics.Add(`Total acknowedged requests:`, 1)
	return `ok`, nil
}

func GetPendingRequests(placeID int) (requests []request, err error) {
	tx, err := db.Begin()
	if err != nil {
		glog.Error(err)
		return requests, err
	} else {
		glog.Info("ERROR ON BEGIN IS NiLL!!!")
	}

	rows, err := tx.Query(`SELECT r.id, r.table_id,  r.menu_item_id, r.place_id, t.id_hash, mi.name, TO_CHAR(r.Inserted_At, 'HH:MI'),
												t.section_color
                        FROM requests r
												join tables t on r.table_id = t.id
												join menu_items mi on r.menu_item_id = mi.id
                        WHERE r.place_id = $1 and r.state_id = 10 and t.is_deleted = false and mi.is_deleted = false order by r.id`, placeID)
	if err != nil {
		glog.Error(err)
		tx.Rollback()
		return requests, err
	}
	defer rows.Close()

	for rows.Next() {
		var request request
		err = rows.Scan(&request.ID, &request.TableID, &request.MenuItemID, &request.PlaceID, &request.TableNumber,
			&request.MenuItemName, &request.InsertedAt, &request.SectionColor)
		if err != nil {
			tx.Rollback()
			return requests, err
		}
		glog.Info("request: ", request)
		requests = append(requests, request)
	}
	if len(requests) == 0 {
		return requests, errors.New("missing_row")
	}

	tx.Commit()
	return requests, err
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

	rows, err := tx.Query(`SELECT p.preferences_json, t.id, t.id_hash, mi.id, mi.name, mi.ordering, p.id, mi.image_url
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
		err = rows.Scan(&table.PreferencesJSON, &table.ID, &table.IDHash, &item.ID, &item.Name, &item.Ordering, &table.PlaceID,
			&item.ImageURL)
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

func expvarHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	fmt.Fprintf(w, "{\n")
	first := true
	expvar.Do(func(kv expvar.KeyValue) {
		if !first {
			fmt.Fprintf(w, ",\n")
		}
		first = false
		fmt.Fprintf(w, "%q: %s", kv.Key, kv.Value)
	})
	fmt.Fprintf(w, "\n}\n")
}
