<?php

namespace Tqdev\PhpCrudApi;

use Tqdev\PhpCrudApi\Api;
use Tqdev\PhpCrudApi\Config\Config;
use Tqdev\PhpCrudApi\RequestFactory;
use Tqdev\PhpCrudApi\ResponseUtils;

require_once 'api.include.php';
 

$config = new Config([
        'driver' => 'sqlite',
        'address' => 'db/sample-data.sqlite',
		'middlewares'=>'dbAuth,authorization,multiTenancy',
		"dbAuth.registerUser"=>"1",
		"dbAuth.usersTable"=>"users",
		"dbAuth.loginTable"=>"active_users",
		'authorization.tableHandler' => function ($operation, $tableName) {
			$current_role = $_SESSION['user']['role_name'];
			$admin_tables = ['offices','roles']; //accessible to admins only
		 	if($current_role =='ADMIN'){
				return true;
			}else{
				return (!in_array($tableName,$admin_tables));
			}
		},
		'authorization.columnHandler'=>function($operation, $tableName, $columnName){
			$hide_columns =['password','created_at','updated_at','deleted_at' ];
			return !($tableName == 'users' && in_array($columnName,$hide_columns));
		},
		'multiTenancy.handler' => function ($operation, $tableName) {
			$current_role = $_SESSION['user']['role_name'] ;
			if($current_role != 'ADMIN' && in_array($operation,['create','list','read','update','increment'])){ 
				return ['created_by' => $_SESSION['user']['id'],'office_id'=>$_SESSION['user']['office_id']];
			}
			if($current_role == 'ADMIN' && $operation =='create'){
				return ['created_by' => $_SESSION['user']['id'],'office_id'=>$_SESSION['user']['office_id']];
			}
		},
		"cacheType"=>"NoCache",
		"debug"=>true
     ]);
$request = RequestFactory::fromGlobals();
$api = new Api($config);
$response = $api->handle($request);
ResponseUtils::output($response);
//filename: my-api.php