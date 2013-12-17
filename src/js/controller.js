var app = angular.module('appCounter', []);
    
app.controller('Controlador', function($scope){
    $scope.resp = 0;

    $scope.sub = function(varResp){
    	// if(variavel == 0){
    	// 	alert('menor');
    	// }
    	// else{
    		$scope.resp = varResp -1;
    	// }
    }
    $scope.add = function(varResp){
    	$scope.resp = varResp +1;
    }

});