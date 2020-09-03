Feature: validar servicio Accounts
        Background:
    * url baseUrl + pathAccount
    * def responseAccount = read('file:data/rta00671612.json')
    * def message_error = read('file:data/error_message_account.json')
    * def cbu = read('file:data/cbuHash.json')
    
        @account
        Scenario Outline: validar servicio Accounts.Cliente:<cliente>
            Given headers {vnd.bbva.user-id: <cliente>, vnd.bbva.user-scope:[accounts.savings.ars.read accounts.current.ars.read]}
             When method GET
             Then status 200
              And print response
        Examples:
                  | cliente    |
                  | '00671612' |
                  | '00925721' |
                  | '00999999' |

        @account
        Scenario Outline: validar respuesta de la consulta de todas las cuentas de un cliente (OK)
    * headers {vnd.bbva.user-id: <cliente>, vnd.bbva.user-scope:[accounts.savings.ars.read accounts.current.ars.read]}

             When method GET
             Then status 200
              And match response == '#[]'
              And match response[0].account_number == responseAccount[0].account_number
              And match response[0].account_type == responseAccount[0].account_type
              And match response[0].cbu == responseAccount[0].cbu
              And match response[0].cbu_hash == responseAccount[0].cbu_hash
              And match response[1].account_number == responseAccount[1].account_number
              And match response[1].account_type == responseAccount[1].account_type
              And match response[1].cbu == responseAccount[1].cbu
              And match response[1].cbu_hash == responseAccount[1].cbu_hash
        Examples:
                  | cliente    |
                  | '00671612' |

        


        @account
        Scenario Outline:  Validar error en el request (Error 400)
            Given headers {vnd.bbva.user-id: <cliente>, vnd.bbva.user-scope:[accounts.savings.ars.read accounts.current.ars.read]}
    * param cbuHash = ''
             When method GET
    * print request
    * print response
             Then status 400
    * print response
    * print message_error.E400
              And match response == message_error.E400
        Examples:
                  | cliente        |
                  | token[0].token |
                  | token[0].token |
                  | token[0].token |

