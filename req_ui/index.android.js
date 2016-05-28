/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableHighlight,
  Image,
  Alert,
  ListView,
  Navigator,
  Animated,
  Dimensions
} from 'react-native';
//import LoadingContainer from 'react-native-loading-container';

import BarcodeScanner from 'react-native-barcodescanner';

var Button = require('react-native-button');



class barbuddy extends Component {
  constructor(props) {
    super(props)
    var ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
    this.state = {
      table_id: '',
      view: 'main',
      menu: undefined,
      preferences_json: undefined,
      api_url: 'http://192.168.1.8:9933/api/',


      btn_color: '#fff',
      btn_background_color: '#286090',
      btn_border_color: '#204d74',

      torchMode: 'off',
      cameraType: 'back',
      barcode: null,

      ds: ds
    }

  }

  render() {
    if(this.state.view == 'main') {
	    return this.renderMainView();
	} else if(this.state.view == 'menu') {
		return this.renderMenuView();
	} else if(this.state.view == 'loading') {
		
		return (
			<View style={{flex: 1, backgroundColor: '#ccc', justifyContent: 'center', alignItems: 'center'}}>
				<Text style={{fontSize: 20}}>Loading...</Text>
			</View>
		);
	} else if(this.state.view == 'scan') {
        return this.renderScannerView();
    }

  }

  barcodeReceived(e) {

  	let qr_data = JSON.parse(e.data);
  	console.log("This ssss ", this);
    this.setState({view: 'main', barcode: e.data, table_id: ""+qr_data.tableID});

    this.GetPlaceAndTableReq(qr_data.tableID);
  }

  renderScannerView() {
  	console.log("Scanner View", this.state)

    return (
      <View style={styles.container}>
          <BarcodeScanner
              onBarCodeRead={this.barcodeReceived.bind(this)}
              style={{ flex: 1 }}
              torchMode={this.state.torchMode}
              cameraType={this.state.cameraType}
          />
          <TouchableHighlight onPress={() => this.setState({view: 'main'})}>
              <View style={{
                    borderColor: '#204d74',
                    borderWidth: 1,
                    backgroundColor: '#286090',
                    justifyContent: 'center',
                    alignItems: 'center',
                    paddingTop: 10,
                    paddingBottom: 10,
                    paddingLeft: 16,
                    paddingRight: 16,
                    height: 58,
              }}>
                  <Text style={{color: '#fff', fontSize: 20}}>BACK</Text>
              </View>
          </TouchableHighlight>
          <TouchableHighlight onPress={() => this.setState(this.state.torchMode == 'on' ? {torchMode: 'off'} : {torchMode: 'on'})}>
              <View style={{
                    borderColor: '#204d74',
                    borderWidth: 1,
                    backgroundColor: '#286090',
                    justifyContent: 'center',
                    alignItems: 'center',
                    paddingTop: 10,
                    paddingBottom: 10,
                    paddingLeft: 16,
                    paddingRight: 16,
                    height: 58,
                  }}>
                <Text style={{color: '#fff', fontSize: 20}}>TORCH</Text>
              </View>
          </TouchableHighlight>
      </View>
    );
  }

  renderMainView() {
  	return (
	      <View style={styles.container}>
	        <View style={{alignItems: 'center'}}>
	          <Text style={{fontSize: 42, marginLeft: 5, fontWeight: 'bold', marginRight: 5, marginBottom: 45}}>CheckPlease</Text>
	        </View>

	        <View style={{borderWidth: 1, borderColor: '#ccc', marginLeft: 5, marginRight: 5, borderRadius: 4}}>
	          <TextInput
	            style={{height: 60, fontSize: 22, color: '#555', borderWidth: 0, backgroundColor: 'white'}}
	            placeholder="Table ID"
	            value={this.state.table_id}
	            onChangeText={table_id => this.setState({table_id})}
	          />
	        </View>

	         <Button
	         	containerStyle={styles.button}
		        style={{fontSize: 20, color: 'white'}}
		        styleDisabled={{color: 'red'}}
		        onPress={this._submitButton.bind(this)}
		      >
		        Submit
		      </Button>

		      <Button
	         	containerStyle={styles.button}
		        style={{fontSize: 20, color: 'white'}}
		        styleDisabled={{color: 'red'}}
		        onPress={this._submitButtonQR.bind(this)}
		      >
		        QR Code Scan
		      </Button>
	      </View>
	    );
  }

  _submitButtonQR() {
  	this.setState({view:'scan'});
  }

  renderMenuView() {
  	_this = this;
  	return (

    	<View style={styles.container}>
	        <View style={{alignItems: 'center'}}>
	          <Text style={{fontSize: 42, marginLeft: 5, marginRight: 5, marginBottom: 35}}>CheckPlease</Text>
	        </View>
	        <View style={{alignItems: 'center'}}>
	        	<Text style={{fontSize: 30, marginLeft: 5, marginRight: 5, marginBottom: 15}}>{this.state.preferences_json.name}</Text>
	        </View>
	        <View>
	        

	        <ListView
		        dataSource={this.state.ds.cloneWithRows(this.state.menu.MenuItems)}
		        renderRow={this.renderMenuButtons}
		        style={styles.listView}
		      />
	        </View>
    	</View>    	
	);
  }

  renderMenuButtons(res) {
  	console.log('Wtf Omg ', res);
  	if(res.ImageURL == null) {
  		return (
  			<TouchableHighlight key={res.ID} onPress={_this._submitMenuButton.bind(_this, res.ID)}>
	          <View style={{
	                borderColor: _this.state.btn_border_color, 
	                borderWidth: 1, 
	                backgroundColor: _this.state.btn_background_color, 
	                justifyContent: 'center', 
	                alignItems: 'center', 
	                marginTop: 10,
	                paddingTop: 10,
	                paddingBottom: 10,
	                paddingLeft: 16,
	                paddingRight: 16,
	                borderRadius: 4,
	                height: 58,
	                marginLeft: 5,
	                marginRight: 5
	              }}>
	            <Text style={{color: _this.state.btn_color, fontSize: 20}}>{res.Name}</Text>
	          </View>
	        </TouchableHighlight>
  		);
  	} else {
	    return (
	      <TouchableHighlight key={res.ID} onPress={_this._submitMenuButton.bind(_this, res.ID)}>
		      <View style={styles.containerProduct}>
		        <Image
		          source={{uri: res.ImageURL}}
		          style={styles.thumbnail}  
		        /> 
		        <Text style={styles.description}>{res.Name}</Text>
		      </View>
	      </TouchableHighlight>
	    );
    }
  }

  _submitButton(event) {
      console.log("EVEEENT ", this.state);
      //this.state.pressStatus = true;

      this.setState({view: "loading"});

      this.GetPlaceAndTableReq();
  }

  GetPlaceAndTableReq(tblID) {
  	console.log("GetPlaceAndTableReqqqqqq ", this.state, tblID);

  	let table_id = tblID ? tblID : this.state.table_id;

  	console.log("tblID table ", table_id)

  	fetch(this.state.api_url, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          method: 'GetPlaceAndTable',
          params: {
            tableID: table_id+""
          },
        })
      })
      .then((response) => response.json())
      .then((responseData) => {
          console.log("Success Resp BTN", responseData);
          console.log("Req obj ", this.state.table_id);


          let preferences_json = JSON.parse(responseData.PreferencesJSON);

          if(responseData.ID == 0) {
          	  Alert.alert(
		        'Table not found',
		        'Please try again',
		         [
		           {text: 'OK', onPress: () => console.log('OK Pressed')},
		         ]
		      );
          } else {
	          this.setState({
	          	view: 'menu',
	          	menu: responseData,
	          	preferences_json: preferences_json
	          });
          }
      })
      .catch((error) => {
        Alert.alert(
        'Error',
        'Please try again',
          [
            {text: 'OK', onPress: () => console.log('OK Pressed')},
          ]
        )
        this.setState({view: "main"});
        console.log("ERRORR ", error)
      })
      .done(() => {
      	console.log("Req DOne");
      });
  }

  //'{"method":"AddRequest", "params":{"tableID":"1", "menuItemID": "1", "placeID":"1"}}' 

  _submitMenuButton(id) {
  	console.log('MenuButton ', id, this)

  	this.setState({view: "loading"});
  	console.log("Conttttt", this.state);

	fetch(this.state.api_url, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          method: 'AddRequest',
          params: {
            tableID: this.state.table_id,
            menuItemID: ""+id,
            placeID: ""+this.state.menu.PlaceID
          },
        })
      })
      .then((response) => {
      	console.log("Response phase ", response);
      	this.setState({view: "menu"});
      	response.json()
      })
      .then((responseData) => {
          console.log("Success Resp MenuBtnzzzzz", responseData);

          Alert.alert(
	        'Success',
	        'Success',
	          [
	            {text: 'OK', onPress: () => console.log('OK Pressed')},
	          ]
	        )
          this.setState({view: "menu"});
      })
      .catch((error) => {
        Alert.alert(
        'Error',
        'Please try again',
          [
            {text: 'OK', onPress: () => console.log('OK Pressed')},
          ]
        )

        this.setState({view: "menu"});

        console.log("ERRORR ", error)
    })
    .done((doneData) => {
    	console.log("Done ", doneData)
    	this.setState({view: "menu"});
    });
    console.log("END conttttz");
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginTop: 20,
    backgroundColor: '#fbfbfc',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  button: {
  	borderColor: '#204d74', 
    borderWidth: 1, 
    backgroundColor: '#286090', 
    justifyContent: 'center', 
    alignItems: 'center', 
    marginTop: 10,
    paddingTop: 10,
    paddingBottom: 10,
    paddingLeft: 16,
    paddingRight: 16,
    borderRadius: 4,
    height: 58,
    marginLeft: 5,
    marginRight: 5,
    overflow: 'hidden'
  },
  buttonPress: {
  	borderColor: '#4cae4c', 
    borderWidth: 1, 
    backgroundColor: '#5cb85c', 
    justifyContent: 'center', 
    alignItems: 'center', 
    marginTop: 10,
    paddingTop: 10,
    paddingBottom: 10,
    paddingLeft: 16,
    paddingRight: 16,
    borderRadius: 4,
    height: 58,
    marginLeft: 5,
    marginRight: 5
  },
  thumbnail: {
    width: 100,
    height: 100,
  },
  description: {
    flex: 1,
    textAlign: 'center',
  },
  containerProduct: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
    borderStyle: 'solid',
    borderColor: '#696969',
    borderBottomWidth: 1,
    padding: 10,
  },
});

AppRegistry.registerComponent('barbuddy', () => barbuddy);
