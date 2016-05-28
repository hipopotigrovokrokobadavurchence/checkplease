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
  ListView
} from 'react-native';

class barbuddy extends Component {
  constructor(props) {
    super(props)

    this.state = {
      table_id: '',
      view: 'main',
      menu: undefined,
      preferences_json: undefined,
      api_url: 'http://192.168.1.5:9933/api/',

      btn_color: '#fff',
      btn_background_color: '#286090',
      btn_border_color: '#204d74'
    }

  }

  render() {
    if(this.state.view == 'main') {
	    return this.renderMainView();
	} else if(this.state.view == 'menu') {
		return this.renderMenuView();
	}
  }

  renderMainView() {
  	return (
	      <View style={styles.container}>
	        <View style={{alignItems: 'center'}}>
	          <Text style={{fontSize: 42, marginLeft: 5, marginRight: 5, marginBottom: 35}}>CheckPlease</Text>
	        </View>

	        <View style={{borderWidth: 1, borderColor: '#ccc', marginLeft: 5, marginRight: 5, borderRadius: 4}}>
	          <TextInput
	            style={{height: 60, fontSize: 22, color: '#555', borderWidth: 0, backgroundColor: 'white'}}
	            placeholder="Table ID"
	            value={this.state.table_id}
	            onChangeText={table_id => this.setState({table_id})}
	            onSubmitEditing={this._submitForm}
	          />
	        </View>
	        <TouchableHighlight onPress={this._submitButton.bind(this)}>
	          <View style={{
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
	                marginRight: 5
	              }}>
	            <Text style={{color: '#fff', fontSize: 20}}>SUBMIT</Text>
	          </View>
	        </TouchableHighlight>
	      </View>
	    );
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
	        {this.state.menu.MenuItems.map(function(res) {
	        	if(typeof res.Name !== "undefined") {
	        		console.log("MAP RES ", res);
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
	          	}
	        })}
	        </View>
    	</View>    	
	);
  }

  _submitButton(event) {
      console.log("EVEEENT ", this.state);

      fetch(this.state.api_url, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          method: 'GetPlaceAndTable',
          params: {
            tableID: this.state.table_id
          },
        })
      })
      .then((response) => response.json())
      .then((responseData) => {
          console.log("Success Resp", responseData);
          this.setState({
          	view: 'menu',
          	menu: responseData,
          	preferences_json: JSON.parse(responseData.PreferencesJSON)
          });
          
      })
      .catch((error) => {
        Alert.alert(
        'Error',
        'Please try again',
          [
            {text: 'OK', onPress: () => console.log('OK Pressed')},
          ]
        )

        console.log("ERRORR ", error)
      })
      .done();
  }

  //'{"method":"AddRequest", "params":{"tableID":"1", "menuItemID": "1", "placeID":"1"}}' 

  _submitMenuButton(id) {
  	console.log('MenuButton ', id)
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
      .then((response) => response.json())
      .then((responseData) => {
          console.log("Success Resp MenuBtn", responseData);
      })
      .catch((error) => {
        Alert.alert(
        'Error',
        'Please try again',
          [
            {text: 'OK', onPress: () => console.log('OK Pressed')},
          ]
        )

        console.log("ERRORR ", error)
    })
    .done();


  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginTop: 50,
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
});

AppRegistry.registerComponent('barbuddy', () => barbuddy);
