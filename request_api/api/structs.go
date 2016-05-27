
type request struct {
    ID          int
    TableID     int
    TableNumber string
    MenuItemID  int
    PlaceID     int
    InsertedAt  time.Time
    InsertedBy  int
    UpdatedAt   time.Time
    UpdatedBy   int
    StateID     int
}

type menuItem struct {
    ID       int
    Name     string
    Ordering int
}

type table struct {
    ID              int
    IDHash          string
    PlaceID         int
    PreferencesJSON string
    MenuItems       []menuItem
}

// JSON RPC requests
type JsonRPCReq struct {
    Method  string
    Params  map[string]string
    ID      int
    jsonrpc string
}

type JsonRPCResp struct {
    jsonrpc string
    error   interface{}
    result  interface{}
}

