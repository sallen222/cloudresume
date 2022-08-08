let apiEndpoint = 'https://9630xasc6c.execute-api.us-east-1.amazonaws.com/';

$.post(apiEndpoint+'counter/counter')

$.getJSON(apiEndpoint+'counter/counter?counterID=resume', function(data){
    document.getElementById("counter").innerHTML = data
})
