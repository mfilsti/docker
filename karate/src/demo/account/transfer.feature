Feature: validar servicio transfer
        Background:
    * url baseUrl + pathTransfer
    * def req = read('file:data/transfer_request.json')
    * def error = read('file:data/error_message_account.json')
    * def response_transfer = read('file:data/transfer_response.json')
    * def cliente = read('file:data/cliente.json')


        Scenario Outline: realizar transferencia
    * headers {vnd.bbva.user-id: <dni>, vnd.bbva.user-scope:[accounts.savings.ars.read accounts.current.ars.read]}
    * set req.document_id = <dni>
    * set req.from_cbu_hash = <from_cbu_hash>
    * set req.to_cbu = <to_cbu>
    * set req.amount = 0.1
              And request req
             When method POST
              And print response
             Then status 201
        Examples:
                  | dni | from_cbu_hash | to_cbu |
                  #| '00699042' | cliente['00699042']['cuentas'][0]['cbu_hash'] | '0150501601000320856887' |
                  | '00671612' | cliente['00671612']['cuentas'][0]['cbu_hash'] | cliente['00938713']['cuentas'][1]['cbu'] |
                  #| '00671612' | cliente['00671612']['cuentas'][1]['cbu_hash'] | cliente['00938713']['cuentas'][1]['cbu'] |
                  #| '00672309' | cliente['00672309']['cuentas'][0]['cbu_hash'] | cliente['00938713']['cuentas'][1]['cbu'] |
                  #| '00938713' | cliente['00938713']['cuentas'][0]['cbu_hash'] | cliente['00672309']['cuentas'][1]['cbu'] |
                  #| '00670996' | cliente['00670996']['cuentas'][0]['cbu_hash'] | cliente['00938713']['cuentas'][1]['cbu'] |
                  #| '00699042' | cliente['00699042']['cuentas'][0]['cbu_hash'] | cliente['00938713']['cuentas'][1]['cbu'] |
                  #| '70383768' | cliente['70383768']['cuentas'][0]['cbu_hash'] | '0150501601000320856887' |



        @transfers
        Scenario Outline: validar respuesta de servicio transfer STATUS CODE 412

    #* def result = call read('login.feature') {dni:<dni>, usuario:<usuario>, password:<password>}
    #* def token = result.accessToken
    #* header Authorization = 'bearer ' + token
    * def cliente = read('classpath:cliente.json')
    * print cliente
    * print cliente['00672309']
    * print cliente['00672309']['cbu']

    * headers {vnd.bbva.user-id: <dni>, vnd.bbva.user-scope:[accounts.savings.ars.read accounts.current.ars.read]}
    * set req.document_id = <dni>
    * set req.from_cbu_hash = <from_cbu_hash>
    * set req.to_cbu = <to_cbu>


            Given request req
             When method POST
    * print response
             Then match response == response_transfer
        Examples:
                  | dni        | from_cbu_hash                                                      | to_cbu                   |
                  | '00672309' | '113a179f757b93e8eaaad48b95cf1e1de1fb1da2da7b2c82185f16aba30e5007' | '0170304520000030079915' |

        @transfers
        Scenario Outline:  validar tope de transferencia permitido
    * headers {vnd.bbva.user-id: <dni>, vnd.bbva.user-scope:[accounts.savings.ars.read accounts.current.ars.read]}
    #* def result = call read('login.feature') {dni:<dni>, usuario:<usuario>, password:<password>}
    #* def token = result.accessToken
    #* header Authorization = 'bearer ' + token
    * set req.amount = <amount>
    * set req.from_cbu_hash = <from_cbu_hash>
    * set req.to_cbu = <to_cbu>
    * set req.document_id = <document_id>
    * print cliente['00671612']['dni']
            Given request req
             When method POST
             Then status <statusCode>
    #* def rta = response
    #* def rta_status = status
             Then match response == <testResponse>

        Examples:
                  | dni        | from_cbu_hash                                 | to_cbu                                   | amount | statusCode | testResponse             | document_id                |
                  | '00699042' | cliente['00699042']['cuentas'][0]['cbu_hash'] | cliente['00938713']['cuentas'][1]['cbu'] | 1500   | 201        | response                 | cliente['00671612']['dni'] |
                  | '00699042' | cliente['00699042']['cuentas'][0]['cbu_hash'] | cliente['00938713']['cuentas'][1]['cbu'] | 500    | 201        | response                 | cliente['00671612']['dni'] |
                  | '00699042' | cliente['00699042']['cuentas'][0]['cbu_hash'] | cliente['00938713']['cuentas'][1]['cbu'] | 2000   | 201        | response                 | cliente['00671612']['dni'] |
                  | '00699042' | cliente['00699042']['cuentas'][0]['cbu_hash'] | cliente['00938713']['cuentas'][1]['cbu'] | 0.1    | 412        | error.E412.limite_diario | cliente['00671612']['dni'] |

        @transfers
        Scenario Outline:  validar error en parametros STATUS CODE 400
    * headers {vnd.bbva.user-id: <dni>, vnd.bbva.user-scope:[accounts.savings.ars.read accounts.current.ars.read]}

    # ver como hacer para que el servicio responda 400
    #* def result = call read('login.feature') {dni:<dni>, usuario:<usuario>, password:<password>}
    #* def token = result.accessToken
    * set req.transfer_code = <transfer_code>
    * set req.currency_code = <currency_code>
    * set req.document_id = <dni>
    * set req.from_cbu_hash = <from_cbu_hash>
    * set req.to_cbu = <to_cbu>
    #* header Authorization = 'bearer ' + token
            Given request req
             When method POST
             Then status 400
    # And match response == error.E400

        Examples:
                  | dni        | usuario     | password   | transfer_code | currency_code | from_cbu_hash                                                      | to_cbu                   |
                  | '00672309' | 'miusuario' | 'micd1122' | 'ALQ'         | 'AAA'         | '113a179f757b93e8eaaad48b95cf1e1de1fb1da2da7b2c82185f16aba30e5007' | '0170118640000000846068' |
                  | '00672309' | 'miusuario' | 'micd1122' | 'ARS'         | 'SIS'         | '113a179f757b93e8eaaad48b95cf1e1de1fb1da2da7b2c82185f16aba30e5007' | '0170118640000000846068' |

  #@transfers
  #Scenario Outline:  validar consulta con credenciales invalidas STATUS CODE 401
  #  * headers {vnd.bbva.user-id: <dni>, vnd.bbva.user-scope:[accounts.savings.ars.read accounts.current.ars.read]}

  #  * def error = read('error_message_account.json')
  #  * def token = read('tokenInvalido.json')
  #  * header Authorization = <token>
  #  When method POST
  #  Then status 401
  #  And match response == <message>

  #  Examples:
  #  | token          | message    |
  #  | token[0].token | error.E401 |
  #  | token[1].token | error.E401 |
  #  | token[2].token | error.E401 |

  @transfers
  #Scenario Outline: validar error cuando alguno de los cbu no existe STATUS CODE 404
    #enviar en request cbu no correspondiente a la cuenta
    #enviar en request cbu filtrado
  #  * headers {vnd.bbva.user-id: <dni>, vnd.bbva.user-scope:[accounts.savings.ars.read accounts.current.ars.read]}
  #  * set req.document_id = <dni>
  #  * set req.from_cbu_hash = <from_cbu_hash>
  #  * set req.to_cbu = <to_cbu>

  #  Given request req
  #  When method POST
  #  Then status 404
  #  And match response == message_error[2]
  #  Examples:
  #    |dni      |usuario    |password  |from_cbu_hash|to_cbu|
  #    |'00672309'|'miusuario'|'micd1122'|'qwdasdad'|'0170118640000000846068'|
  #    |'00672309'|'miusuario'|'micd1122'|'113a179f757b93e8eaaad48b95cf1e1de1fb1da2da7b2c82185f16aba30e5007'|'asdasdad'|


        @transfers
        Scenario Outline:  transferir hacia misma cuenta de origen STATUS CODE 412
    * headers {vnd.bbva.user-id: <dni>, vnd.bbva.user-scope:[accounts.savings.ars.read accounts.current.ars.read]}

  # por ejemplo, la Cuenta de la cuenta no tiene saldo suficiente o está bloqueada, cancelada
    #* def result = call read('login.feature') {dni:<dni>, usuario:<usuario>, password:<password>}
    #* def token = result.accessToken
    #* header Authorization = 'bearer ' + token
    * set req.document_id = <dni>
    * set req.from_cbu_hash = <from_cbu_hash>
    * set req.to_cbu = <to_cbu>
            Given request req
             When method POST
             Then status 412
              And print response
              And match response == error.E412.misma_cuenta

        Examples:
                  | dni        | usuario     | password   | from_cbu_hash                                                      | to_cbu                   |
                  | '00672309' | 'miusuario' | 'micd1122' | '113a179f757b93e8eaaad48b95cf1e1de1fb1da2da7b2c82185f16aba30e5007' | '0170118640000000846068' |

        @transfers
        Scenario Outline: transferir con saldo insuficiente
    * headers {vnd.bbva.user-id: <dni>, vnd.bbva.user-scope:[accounts.savings.ars.read accounts.current.ars.read]}
    * set req.document_id = <dni>
    * set req.from_cbu_hash = <from_cbu_hash>

    #* def result = call read('login.feature') {dni:<dni>, usuario:<usuario>, password:<password>}
    #* def token = result.accessToken
    #* header Authorization = 'bearer ' + token
            Given request req
             When method POST
             Then status 412
              And match response == error.E412.saldo_insuficiente
        Examples:
                  | dni        | usuario     | password   | from_cbu_hash                                                      |
                  | '70383768' | 'miusuario' | 'micd1122' | '8b9d92005f7f36711ca83bf6ec1e9e34ba1a3e0bc0137f51b1254019fd44e2a4' |

        @transfer_reques
        Scenario Outline: transferir hacia una cuenta invalida
     * headers {vnd.bbva.user-id: <dni>, vnd.bbva.user-scope:[accounts.savings.ars.read accounts.current.ars.read]}
     * set req.document_id = <dni>
     * set req.from_cbu_hash = <from_cbu_hash>
     * set req.to_cbu = <to_cbu>
     #* def result = call read('login.feature') {dni:<dni>, usuario:<usuario>, password:<password>}
    #* def token = result.accessToken
    #* header Authorization = 'bearer ' + token
            Given request req
             When method POST
             Then status 412
              And match response == error.E412.cuenta_invalida

        Examples:
                  | dni        | usuario     | password   | from_cbu_hash                                                      | to_cbu                   |
                  | '70383768' | 'miusuario' | 'micd1122' | '6432859aac7c2b7c23364f702974728e048ddde83a22dd3d385629b619b8c4f5' | '0170295020000000116260' |





    

  

