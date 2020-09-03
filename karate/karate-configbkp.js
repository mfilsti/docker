function fn() {    
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
  baseUrl: 'http://chanacco:7071',
  pathAccount:'/apibbvachannel/accounts/accounts',
  pathTransfer:'/apibbvachannel/transfers/transfers',
  pathComunication:'',

  }
  if (env == 'test') {
  } else if (env == 'docker') {
  config.baseUrl = 'http://was90test1';
  }
  return config;
}