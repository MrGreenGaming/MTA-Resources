<?php
/**
************************************
* MTA PHP SDK
************************************
*
* @copyright	Copyright (C) 2010, Multi Theft Auto
* @author		JackC, eAi, Sebas
* @link			http://www.mtasa.com
* @version		0.4
*/

class mta
{
	private $useCurl = false;
	private $sockTimeout = 6; // seconds
	
	public $http_username = '';
	public $http_password = '';
	
	public $host = '';
	public $port = '';
	
	private $resources = array();
	
	public function __construct( $host, $port, $username = "", $pass = "" )
	{
		$this->host = $host;
		$this->port = $port;
		$this->http_username = $username;
		$this->http_password = $pass;
	}
	
	public function getResource ( $resourceName )
	{
		foreach ( $this->resources as $resource )
		{
			if ( $resource->getName == $resourceName )
				return $resource;
		}
		
		$res = new Resource ( $resourceName, $this );
		$this->resources[] = $res;
		return $res;
	}
	
	public static function getInput()
	{
		$out = mta::convertToObjects( json_decode( file_get_contents('php://input'), true ) );
		return (is_array($out)) ? $out : false;
	}
	
	public static function doReturn()
	{
		$val = array();
		
		for ( $i = 0; $i < func_num_args(); $i++ )
		{
			$val[$i] = func_get_arg($i);
	    }
		
		$val = mta::convertFromObjects($val);
		$json_output = json_encode($val);
		echo $json_output;
	}
	
	public function callFunction( $resourceName, $function, $args )
	{
		if ( $args != null )
		{
			$args = mta::convertFromObjects($args);
			$json_output = json_encode($args);
		}
		else
		{
			$json_output = "";
		}
		$path = "/" . $resourceName . "/call/" . $function;
		$result = $this->do_post_request( $this->host, $this->port, $path, $json_output );
		// echo $json_output;
		$out = mta::convertToObjects( json_decode( $result, true ) );
		
		return (is_array($out)) ? $out : false;
	}
	
	public static function convertToObjects( $item )
	{
		if ( is_array($item) )
		{
			foreach ( $item as &$value ) 
			{
				$value = mta::convertToObjects( $value );
			}
		}
		else if ( is_string($item) )
		{	
			if ( substr( $item, 0, 3 ) == "^E^" )
			{
				$item = new Element( substr( $item, 3 ) );
			}
			elseif ( substr( $item, 0, 3 ) == "^R^" )
			{
				$item = $this->getResource( substr( $item, 3 ) );
			}
		}
		
		return $item;
	}
	
	public static function convertFromObjects( $item )
	{
		if ( is_array($item) )
		{
			foreach ( $item as &$value ) 
			{
				$value = mta::convertFromObjects($value);
			}
		}
		elseif ( is_object($item) )
		{	
			if ( get_class($item) == "Element" || get_class($item) == "Resource" )
			{
				$item = $item->toString();
			}
		}
		
		return $item;
	}
	
	function do_post_request( $host, $port, $path, $json_data )
	{
		if ( $this->useCurl )
		{
			$ch = curl_init();   
			curl_setopt( $ch, CURLOPT_URL, "http://{$host}:{$port}{$path}" ); 
			curl_setopt( $ch, CURLOPT_POST, 1 );
			curl_setopt( $ch, CURLOPT_POSTFIELDS, $json_data );
			$result = curl_exec($ch);    
			curl_close($ch); 
			return $result;
		}
		else
		{
			if ( !$fp = @fsockopen( $host, $port, $errno, $errstr, $this->sockTimeout ) )
			{
				throw new Exception( "Could not connect to {$host}:{$port}" );
			}

			$out = "POST {$path} HTTP/1.0\r\n";
			$out .= "Host: {$host}:{$port}\r\n";
			
			if ( $this->http_username && $this->http_password )
			{
				$out .= "Authorization: Basic " . base64_encode( "{$this->http_username}:{$this->http_password}" ) . "\r\n";
			}
			
			$out .= "Content-Length: " . strlen($json_data) . "\r\n";
			$out .= "Content-Type: application/x-www-form-urlencoded\r\n\r\n";
			//$out .= "Connection: close\r\n\r\n";
			$out .= $json_data . "\r\n\r\n";
			
			if ( !fputs( $fp, $out ) )
			{
				throw new Exception( "Unable to send request to {$host}:{$port}" );
			}
			
			@stream_set_timeout( $fp, $this->sockTimeout );
			$status = @socket_get_status($fp);
			
			$response = '';
			
			while ( !feof($fp) && !$status['timed_out'] )
			{
				$response .= fgets( $fp, 128 );
				$status = socket_get_status($fp);
			}
			
			fclose( $fp );
			
			$tmp = explode( "\r\n\r\n", $response, 2 );
			$headers = $tmp[0];
       		$response = trim($tmp[1]);
       		
       		preg_match( "/HTTP\/1.(?:0|1)\s*([0-9]{3})/", $headers, $matches );
       		$statusCode = intval($matches[1]);
       		
       		if ( $statusCode != 200 )
       		{
       			switch( $statusCode )
       			{
       				case 401:
       					throw new Exception( "Access Denied. This server requires authentication. Please ensure that a valid username and password combination is provided." );
       				break;
       				
       				case 404:
       					throw new Exception( "There was a problem with the request. Ensure that the resource exists and that the name is spelled correctly." );
       				break;
       			}
       		}
       		
       		if ( preg_match( "/^error/i", $response ) )
       		{
       			throw new Exception( ucwords( preg_replace("/^error:?\s*/i", "", $response ) ) );
       		}
			
			return $response;
		}
	}
}

class Element
{
	var $id;

	function Element($id)
	{
		$this->id = $id;
	}

	function toString()
	{
		return "^E^" . $this->id;
	}
}


class Resource
{
	var $name;
	private $server;

	function Resource($name, $server)
	{
		$this->name = $name;
		$this->server = $server;
	}

	function toString()
	{
		return "^R^" . $this->name;
	}
	
	public function getName()
	{
		return $this->name;
	}
	
	function call ( $function )
	{
		
		$val = array();
		
		for ( $i = 1; $i < func_num_args(); $i++ )
		{
			$val[$i-1] = func_get_arg($i);
	    }
		return $this->server->callFunction ( $this->name, $function, $val );
	}
}
?>