package main

type app struct {
}

/*
type clientUser struct {
	ID         int
	IDHash     string
	FirstName  *string
	LastName   *string
	Login      *string
	Password   *string
	Email      *string
	InsertedAt time.Time
	InsertedBy int
	UpdatedAt  time.Time
	UpdatedBy  int
}

type menuItem struct {
	ID         int
	Name       *string
	Ordering   int
	PlaceID    int
	InsertedAt time.Time
	InsertedBy int
	UpdatedAt  time.Time
	UpdatedBy  int
}

type owner struct {
	ID         int
	IDHash     string
	FirstName  *string
	LastName   *string
	Login      *string
	Password   *string
	Email      *string
	InsertedAt time.Time
	UpdatedAt  time.Time
}

type place struct {
	ID              int
	IDHash          string
	PreferencesJSON string
	InsertedAt      time.Time
	InsertedBy      int
	UpdatedAt       time.Time
	UpdatedBy       int
}



type table struct {
	ID      int
	IDHash  string
	Number  string
	PlaceID int
}
*/

type request struct {
	ID           int
	TableID      int
	TableNumber  string
	MenuItemID   int
	MenuItemName string
	PlaceID      int
	InsertedAt   string
	InsertedBy   int
	UpdatedAt    string
	UpdatedBy    int
	StateID      int
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
