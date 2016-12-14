'use strict';

/* Controllers */

var app = angular.module('app', [])
.controller('NavCtrl', ['$scope', '$http', '$interval', function($scope, $http, $interval) {

  $scope.depth = 10;

  $scope.showNode = function($node) {
    if($node.depth <= $scope.depth) {
      return true;
    }
  };

  $scope.remapNodes = function($node, $depth, $theNode, $del) {

    $node.depth = $depth;
    $depth++;

    if (undefined == $node.nodes) {
      $node.nodes = [];
    }

    if(undefined !== $theNode && $theNode.parent == $node.id) {
      // if there is a new node and we found a parent
      // if delete
      if($del) {
        var $arrayLength = $node.nodes.length;

        for (var $i = 0; $i < $arrayLength; $i++) {
          var $nextNode = $node.nodes[$i];
          if($theNode.id == $nextNode.id) {
            $node.nodes.splice($i, 1);
            break;
          }
        }

      } else {
        $node.nodes.push($theNode);
      }
    }

    var $arrayLength = $node.nodes.length;

    for (var $i = 0; $i < $arrayLength; $i++) {
      var $nextNode = $node.nodes[$i];
      $scope.remapNodes($nextNode, $depth, $theNode, $del);
    }
  };

  $scope.masterNode = null;

  // populate masterNode with nodes on page load
  $http.get('/app/nodes/'+ 1).success(function($nodes) {
    // add depth value to each node
    $scope.remapNodes($nodes, 0);
    $scope.masterNode = $nodes;
    if( null == $scope.masterNode.parent ) {
      // master node does not have a parent
      $scope.masterNode.parent = 'NONE';
    }
  }).error(function($data) {
    $scope.errorMessage = $data.errorMessage;
  });

  $scope.addNode = function($PID) {
    $http.get('/app/addNode/'+ $PID).success(function($data) {
      // update nodes: put new node under it's parent
      $scope.remapNodes($scope.masterNode, 0, $data);
    }).error(function($data) {
      // display error message
      $scope.errorMessage = $data.errorMessage;
      // hide after delay
      $interval(function() {
        $scope.errorMessage = null;
      }, 3000);
    });
  };

  $scope.delNode = function($node) {
    try {
      $http.get('/app/delNode/'+ $node.id).success(function($data) {
        // update nodes: put new node under it's parent
        $scope.remapNodes($scope.masterNode, 0, $node, 'del');
      }).error(function($data) {
        // display error message
        $scope.errorMessage = $data.errorMessage;
        // hide after delay
        $interval(function() {
          $scope.errorMessage = null;
        }, 3000);
      });
    } catch($err) {
      console.log('error caught', $err);
    }
  };

}]);
