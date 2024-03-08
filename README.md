# Taller Práctico de Seguridad en Smart Contracts - HackersWeek X

¡Bienvenidos al taller práctico sobre seguridad en Smart Contracts, organizado por el grupo de investigación [NICS Lab](https://www.nics.uma.es/) de la Universidad de Málaga, con motivo de celebración de la HackersWeek X organizada por el Consejo de Estudiantes!

## Descripción del Taller

El taller tuvo lugar el pasado 5 de marzo, en él nos sumergiremos en las fascinantes bases de la tecnología Blockchain y exploraremos cómo este innovador paradigma proporciona un entorno seguro, destacando su aplicación principal en las criptomonedas. A través de los principios de descentralización e igualdad entre nodos, descubrimos cómo la Blockchain se convierte en una herramienta crucial para la garantía de seguridad en transacciones digitales.

Posteriormente, nos adentramos en el lenguaje de programación Solidity, una pieza fundamental para la creación de contratos inteligentes. Estos contratos, ejecutados de manera descentralizada y segura en los nodos de la Blockchain, sientan las bases de la web3, llevándonos un paso más cerca de la descentralización completa en la web.

## Contenido Teórico del Taller

A continuación ofrecemos contenido para aquellos que no pudieron disfrutar del taller en directo, o para aquellos que deseen repasar los conceptos aprendidos. 

- [Blockchain - Ethereum](https://ethereum.org/es/developers/docs/intro-to-ethereum/#what-is-a-blockchain)

- [Contratos Inteligentes](https://ethereum.org/es/developers/docs/smart-contracts/)

- [Solidity](https://docs.soliditylang.org/en/v0.8.24/introduction-to-smart-contracts.html)

- [Nodos](https://ethereum.org/es/developers/docs/nodes-and-clients/)

- [Redes](https://ethereum.org/es/developers/docs/networks/)

- [Mecanismos de Concenso](https://ethereum.org/es/developers/docs/consensus-mechanisms/)

- [Pila de Ethereum](https://ethereum.org/es/developers/docs/ethereum-stack/)

- [Seguridad](https://ethereum.org/es/developers/docs/smart-contracts/security/) 

# Pasemos a la Práctica!

## Requisitos

### IDE

Vamos a necesitar un entorno de desarrollo integrado, podemos utilizar cualquier IDE que nos guste, por ejemplo:

- [Visual Studio Code](https://code.visualstudio.com/)

### Foundry

Lo siguiente que necesitamos es instalar un framework de desarrollo para Solidity.

Foundry está compuesto por cuatro componentes:
- [**Forge**](https://github.com/foundry-rs/foundry/blob/master/crates/forge): Ethereum Testing Framework
- [**Cast**](https://github.com/foundry-rs/foundry/blob/master/crates/cast): Una herramienta de línea de comandos para realizar llamadas RPC a Ethereum. Permitiendo interactuar con contratos inteligentes, enviar transacciones o recuperar cualquier tipo de datos de la Blockchain mediante la consola.
- [**Anvil**](https://github.com/foundry-rs/foundry/blob/master/crates/anvil): Un nodo local de Ethereum, similar a Ganache, el cual es desplegado por defecto durante la ejecución de los tests.
- [**Chisel**](https://github.com/foundry-rs/foundry/blob/master/crates/chisel): Un REPL de solidity, muy rápido y útil durante el desarrollo de contratos o testing.


>**¿Por qué Foundry?**
>- Es el framework más rápido
>- Permite escribir test y scripts en Solidity, minimizando los cambios de contexto
>- Cuenta con muchísimos cheatcodes para testing y debugging


La forma recomendada de instalarlo es mediante la herramienta **foundryup**.


> [!NOTE]
> Si usas Windows, necesitarás instalar y usar [Git BASH](https://gitforwindows.org/) o [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) como terminal, ya que Foundryup no soporta Powershell o Cmd.
> 


En la terminal ejecuta:

`curl -L https://foundry.paradigm.xyz | bash`

Como resultado obtendrás algo parecido a esto:

`Detected your preferred shell is bashrc and added Foundry to Path run:source /home/user/.bashrcStart a new terminal session to use Foundry`

Ahora simplemente escribe `foundryup` en la terminal y pulsa `Enter`. Esto instalará los cuatro componentes de Foundry: *forge*, *cast*, *anvil* y *chisel*.

Para confimar la correcta instalación escribe `forge --version`. Deberías de obtener la versión instalada de forge:
`Forge version x.x.x`

Si no has obtenido la versión, es posible que necesites añadir Foundry a tu PATH. Para ello, puedes ejecutar lo siguiente:
`cd ~echo 'source /home/user/.bashrc' >> ~/.bash_profile`

Si aún así sigues teniendo problemas con la instalación, puedes seguir las instrucciones de instalación de Foundry en su [repositorio](https://book.getfoundry.sh/getting-started/installation).

Aún así, si no puedes instalar Foundry, no te preocupes, puedes seguir el taller utilizando [Remix](https://remix.ethereum.org/), un IDE online para Solidity.

## Primeros Pasos

Lo primero que vamos a hacer es clonar el repositorio del taller. Para ello, abre una terminal y ejecuta:

```
# Clonamos el repo:
https://github.com/nicslabdev/HackerWeekX-Web3-workshop.git

# Abrimos la carpeta creada
cd HackerWeekX-Web3-workshop

# Instalamos las dependencias
forge install foundry-rs/forge-std --no-commit
```

Deberiamos de ver algo así:

![Screenshot_01](/resources/Screenshot_01.png)

Podemos comprobar que todo está correcto ejecutando `forge build`, lo cual compilará  el contrato inteligente que vamos a utilizar en el taller. 

Deberiamos de obtener el siguiente resultado:

![Screenshot_02](/resources/Screenshot_02.png)

## Contenido del Repositorio

### Crowdfund

En la carpeta `/src` podemos encontrar el contrato inteligente que vamos a estudiar, `Crowdfund.sol`. Este contrato es una nueva versión del contrato usado en el taller, `Subasta.sol`, con algunas mejoras y cambios pero con la misma estructura general.

El siguiente diagrama nos ayudará a comprender el contrato inteligente, destacando las variables constantes, las variables de estado y las funciones que realizan cambios en el estado del contrato, junto a los distintos perfiles de usuario que interactúan con él.

![Diagrama_01](/resources/Diagrama_01.png)

#### Variables:
- **STAKE_TARGET**: Target de inversión para el crowdfunding (1000 finney == 1 ether).
- **MAX_ADMISSIBLE_STAKE_INCREASE**: Máximo incremento de inversión permitido (100 finney == 0.1 ether).
- **MIN_ADMISSIBLE_STAKE_INCREASE**: Mínimo incremento de inversión permitido (2 finney == 0.002 ether).
- **stakes**: Mapeo de las inversiones de cada inversor. (Si `stakes[msg.sender] == 1` implica que msg.sender es el owner)
- **maxStake**: Máxima inversión actual. (Si `maxStake == 0` implica que el crowdfunding está cerrado)
- **leadInvestor**: Dirección del inversor mayoritario.

#### Funciones que modifican el estado del contrato:
- **stake()**: Función *payable* que permite a los usuarios realizar inversiones.
- **closeFund()**: Función que permite al **owner** cerrar el crowdfunding y retirar el 90% de los fondos recaudados. 
- **withdraw()**: Función que permite al **inversor principal** retirar el 10% de los fondos recaudados, una vez finalizado el crowdfunding.

Este diagrama nos ayuda a comprender en primera instancia los puntos de acceso del contrato y los distintos actores que interactuan con él. Pero para entender el contrato en su totalidad, y poder comprobar su correcto funcionamiento, debemos de seguir profundizando en el código. 

Ya sabemos qué actores interactúan con cada punto de acceso, el siguiente paso sería ver qué comprobaciones se realizan en cada función, y cómo actualizan el estado. 

![Diagrama_02](/resources/Diagrama_02.png)

Ahora podemos analizar el comportamiento del contrato en su totalidad, vayamos por partes:

- **constructor()**: 
  - Inicializa el contrato, abriendo el crowdfunding y asignando al msg.sender como owner.
- **stake()**: 
  - Comprueba que:
    - El msg.sender no sea el owner.
    - El crowdfunding esté abierto.
    - El incremento de la inversión sea múltiplo de 1 finney.
    - El incremento de la inversión sea mayor que 2 y menor o igual que 100 finney.
  
  - Actualiza la inversión actual del msg.sender, sumando el valor enviado.
  - Comprueba si la inversión actual del msg.sender es mayor que la del inversor mayoritario, y si es así, actualiza el inversor mayoritario.
- **closeFund()**: 
  - Comprueba que:
    - El msg.sender sea el owner.
    - El crowdfunding esté abierto.
    - El target de inversión se haya alcanzado.
  
  - Cierra el crowdfunding.
  - Envía al owner el 90% de los fondos obtenidos.
- **withdraw()**: 
  - Comprueba que:
    - El crowdfunding esté cerrado.
    - El msg.sender sea el inversor mayoritario.
  
  - Envía al inversor mayoritario el 10% de los fondos obtenidos. (El balance restante del contrato, pues el owner ya ha retirado el 90%)
  
> [!IMPORTANT]
> Una vez analizado el código, observamos que el contrato está diseñado siguiendo las siguientes reglas:
> - Usa el finney como unidad del ether.
> - El owner es el único que puede cerrar el crowdfunding, y se lleva el 90% de los fondos.
> - El inversor mayoritario es el único que puede retirar el 10% restante.
> - Si `stakes[msg.sender] == 1` implica que msg.sender es el owner
> - Si `maxStake == 0` implica que el crowdfunding está cerrado


### Tests

En la carpeta `/test` encontramos el archivo `Crowdfund.t.sol` que contiene los test de `Crowdfund.sol`. Estos tests están escritos en Solidity, y se ejecutan con el comando `forge test`. 

La estructura típica de los tests es la siguiente:
    
``` 
// SPDX-License-Identifier: GPL-3.0
pragma solidity x.x.x;

import {Test, console} from "@forge-std/Test.sol";
import {Contract} from "../src/Contract.sol";

contract Contract_Test is Test{
    Contract public targetContract;

    /************************************** Variables **************************************/

    // ...

    /************************************** Modifiers **************************************/

    modifier doSomethingBefore() {
        // ...
        _;
    }


    /**************************************** Set Up ***************************************/

    function setUp() public {
        // ...
    }

    /***************************************** Tests ****************************************/

    function testSomeFunction() public {
        // ...
    }

    function testAnotherFunction() doSomethingBefore() public {
        // ...
    }

}
    
```

Como podemos observar, en Foundry los tests también están escritos en solidity, y siguen una estructura similar a la de un contrato inteligente. En ellos podemos definir las variables que vamos a utilizar, los modificadores que vamos a aplicar, y las funciones que vamos a testear.

> [!TIP]
> - Usamos los modifier para modificar el comportamiento de otras funciones. En este caso, el modifier `doSomethingBefore()` modifica el comportamiento de la función `testAnotherFunction()`, de forma que se ejecuta el contenido del modifier antes que el de la función.
> - La función setUp es especial, se ejecuta antes de cada test, y nos permite inicializar las variables que vamos a utilizar en ellos.

Dicho esto, vamos a ejecutar los tests para comprobar que el contrato funciona correctamente. Para ello, ejecutamos `forge test --match-contract Crowdfund` en la terminal. Deberiamos de obtener el siguiente resultado:

![Screenshot_03](/resources/Screenshot_03.png)

Vaya... Parece que no hay ningún error, ¡Esto significa que el contrato es seguro! ¿O no...?

![testing_meme](/resources/testing_meme.png)


> [!WARNING]
> Los tests no son infalibles, y en la mayoría de los casos son escritos por el mismo desarrollador que diseñó el contrato, lo que significa que pueden estar sesgados.

## Análisis de Seguridad - Simulacro de Auditoría

Ahora es el momento de analizar el contrato en busca de vulnerabilidades. Lo ideal sería que dejases de leer y lo analizaras por tu cuenta. Para ello te facilito una [lista de vulnerabilidades comunes](https://owasp.org/www-project-smart-contract-top-10/) y te recomiendo que sigas los siguientes pasos:

1. **Revisa las comprobaciones de las funciones**: ¿Se están realizando todas las comprobaciones necesarias? ¿Se están realizando correctamente?
2. **Revisa las actualizaciones del estado**: ¿Se están actualizando correctamente las variables de estado? ¿Se están actualizando en el orden correcto?
3. **Revisa los controles de acceso**: ¿Están bien definidos los perfiles de usuario? ¿Pueden ser modificados?
   
Si no encuentras nada, puedes cambiar de perspectiva y analizar el contrato desde el punto de vista de un atacante. ¿Qué harías si quisieras atacar el contrato? ¿Qué vulnerabilidades buscarías?

Como atacante, lo primero que haría sería buscar la forma de hacerme con el control del contrato, es decir ganar el perfil de owner. ¿Cómo podría hacerlo? Intenta encontrar una forma de hacerlo, y después sigue leyendo.

Bien, como comentamos anteriormente si `stakes[msg.sender] == 1` implica que msg.sender es el owner. ¿Qué pasaría si encontramos una forma de que se cumpla esta condición cuando somos msg.sender? ¿Cómo podríamos hacerlo?

Parece realmente fácil, ¿verdad? Bastaría con hacer stake con 1 finney, sin haber hecho ninguna inversión previa, y ya seríamos el owner. ¡Escribamos un test!

> [!NOTE]
> Este paso vamos a hacerlo juntos, primero en Foundry, y después en Remix para aquellos que no puedan utilizar Foundry.

#### Foundry

Para ello vamos a añadir un nuevo test al final del archivo `Crowdfund.t.sol`: 

![Screenshot_04](/resources/Screenshot_04.png)

> [!NOTE]
>Es importante que la función comience por `test`, para que sea detectada por el comando `forge test`. 

Debemos de recordar que antes de cada test se ejecuta la función `setUp`, veamos qué hace... 

``` 
    // La función setUp() es ejecutada antes de cada test para establecer el escenario inicial
    function setUp() public {
        // Aumentamos el balance de cada usuario
        // La unidad por defecto es el wei, por lo que 1 ether = 1000 finney = 1e18 wei 
        // Como DECIMALS es 10**15, estamos asignando 300 finney a cada usuario
        vm.deal(owner, 300 * DECIMALS);
        vm.deal(user1, 300 * DECIMALS);
        vm.deal(user2, 300 * DECIMALS);
        vm.deal(user3, 300 * DECIMALS);
        vm.deal(user4, 300 * DECIMALS);
        vm.deal(user5, 300 * DECIMALS);

        // El owner despliega el contrato
        vm.prank(owner);
        crowfundContract = new Crowdfund();
    }
```

Como podemos observar, al principio recarga el balance de cada usuario con 300 finney, y después despliega el contrato desde la dirección del owner.

> [!TIP]
> Unidades: 
>
> | Unit   | Denominations                             |         |
> | ------ | ----------------------------------------- | ------- |
> | Wei    | 1                                         |         |
> | Kwei   | 1,000                                     | (10^3)  |
> | Mwei   | 1,000,000                                 | (10^6)  |
> | Gwei   | 1,000,000,000                             | (10^9)  |
> | Szabo  | 1,000,000,000,000                         | (10^12) |
> | Finney | 1,000,000,000,000,000                     | (10^15) |
> | Ether  | 1,000,000,000,000,000,000                 | (10^18) |
> | KEther | 1,000,000,000,000,000,000,000             | (10^24) |
> | MEther | 1,000,000,000,000,000,000,000,000         | (10^24) |
> | GEther | 1,000,000,000,000,000,000,000,000,000     | (10^27) |
> | TEther | 1,000,000,000,000,000,000,000,000,000,000 | (10^30) |

Ahora que sabemos esto, podemos escribir el test. 

``` 
    // Test para comprobar que el owner puede ser cambiado
    function test_stake_ObtainingOwnership() public {
        vm.prank(user1);                                         // Esto indica que la siguiente llamada se hará como user1 (msg.sender = user1)
        crowfundContract.stake{value: 1 * DECIMALS}();           // Llamamos a stake() con user1 y 1 Finney
        assertEq(uint(crowfundContract.stakes(user1)), 1);       // Comprobamos que el owner ha cambiado
    }
```

Para ejecutar el test escribimos lo siguiente en la terminal: `forge test --match-test test_stake_ObtainingOwner`

![Screenshot_05](/resources/Screenshot_05.png)

Vaya... parece que el test ha fallado. ¿Qué ha pasado? ¿Por qué no hemos obtenido el resultado esperado?

#### Remix

Para aquellos que no puedan utilizar Foundry, vamos a hacer la prueba en Remix.

Copiamos el contrato `Crowdfund.sol` en el editor de Remix y lo compilamos con la versión correcta del compilador.

![Screenshot_06](/resources/Screenshot_06.png)

Después desplegamos el contrato en la red de Remix.

![Screenshot_07](/resources/Screenshot_07.png)

En el desplegable de *Deployed Contracts* nos aparecerán todas las funciones del contrato con las que podemos interactuar. 

![Screenshot_08](/resources/Screenshot_08.png)

Vemos que stake está en rojo porque es una función *payable*, para interactuar con ella debemos de:

- Cambiar de cuenta pues ahora mismo estamos con la que desplegó el contrato, es decir, el owner. Podemos comprobarlo por el balance de la cuenta, que es menor que las de el resto por el gasto del despliegue.

![Screenshot_09](/resources/Screenshot_09.png)

- Asignar **1 finney** como msg.value en el campo *value*.
- Pulsar el botón *stake*.
 
![Screenshot_10](/resources/Screenshot_10.png)

Observamos que la transacción falla, al igual que el test de Foundry... 

![Screenshot_11](/resources/Screenshot_11.png)

Pero, ¿Por qué? ¿Qué ha pasado? ¿Puedes ver por qué ha fallado?

Exacto, habiamos olvidado que la función `stake()` comprueba que la inversión sea mayor que 2 finney... Vamos a tener que buscar otra forma de hacernos con el control del contrato.

## Vulnerabilidad

> [!WARNING]
> SPOILER: La vulnerabilidad se encuentra en la función 'stake()', y se trata de un **desbordamiento de enteros**. ¿Eres capaz de encontrarla?

Bueno, si no has sido capaz, no te preocupes, vamos a hacerlo juntos.

Una de las *red flags* que nos debería de llamar la atención es que el contrato usa una versión de Solidity **anterior a la 0.8.0**.

> [!IMPORTANT]
> Las versiones anteriores a la 0.8.0 no tienen comprobaciones de desbordamiento de enteros, lo que significa que si realizamos una operación que desborde el rango de un entero, el contrato no nos avisará. 

> [!CAUTION]
> Esto no significa que en versiones posteriores a la 0.8.0 no se puedan producir desbordamientos de enteros. De hecho, si la operación se realiza en [código ensamblador](https://solidity-es.readthedocs.io/es/latest/assembly.html), Solidity no podrá comprobarlo.

Esto nos deja con una pista muy clara de por dónde buscar. Recordemos nuestro objetivo principal, obtener el control del contrato, es decir, **ganar el perfil de owner**.

Para ello, debemos de buscar una forma de que `stakes[msg.sender] == 1`- siendo nosotros msg.sender. Como sabemos que en esta versión de Solidity no se realizan comprobaciones de desbordamiento, podemos intentar realizar una suma que desborde el rango del entero, y así obtener el control del contrato.

El mapping `stakes` es un mapeo de direcciones a enteros de 256 bits -> [0, 255]. Por lo que si hacemos un stake de 257 finney, el resultado será 1, pues 257 % 256 = 1.

Pero no cometamos el mismo error que antes, ya sabemos que las inversiones deben de ser mayores que 2 finney y menores o iguales que 100. Por lo que no podemos hacer un stake de 257 finney. Debemos de hacerlo en, como mínimo, tres transacciones. 


## Prueba de Concepto - *Exploit*

De forma que un *exploit* podría ser el siguiente:
1. Hacer un stake de 100 finney
2. Hacer un stake de 100 finney
3. Hacer un stake de 57 finney

Sería muy interesante que intentaras realizar el *exploit* por tu cuenta. 

Si estás usando Foundry, puedes hacerlo en el archivo `Crowdfund.t.sol`, añadiendo un nuevo test, tal y como hemos hecho antes. 

>[!TIP]
>Usa como guía los test que ya están escritos.

Y si estás usando Remix, puedes hacerlo siguiendo los pasos realizados anteriormente.   
- Compila y despliega el contrato.
- Interactúa con el contrato mediante el desplegable de *Deployed Contracts*. Recuerda que necesitarás cambiar de cuentas, que la primera es la del owner y que la unidad con la que trabajamos es el finney.

No te preocupes si no puedes realizar el *exploit*, también vamos a hacerlo juntos, primero en Foundry y después en Remix.

#### Foundry

Puede que te hayas percatado de que en la carpeta `/test` hay un archivo llamado `ProofOfConcept.t.sol`. Este archivo contiene el test que vamos a utilizar para explotar el contrato.	

Está compuesto por:

- **setUp()**: Función que se ejecuta antes de cada test para establecer el escenario inicial. En este caso, recarga el balance de cada usuario con 300 finney, y despliega el contrato desde la dirección del owner.
- **stake(address user, uint amount)**: Función que realiza un stake con el usuario y la cantidad especificada.
- **exploit()**: Función que realiza el ataque.
- **test_exploit()**: Test que lo orquesta. Esta es la función que ejecutaremos, por lo que vamos a analizarla:


![Screenshot_12](/resources/Screenshot_12.png)

Observamos que, antes de hacer el *exploit*, se realizan stakes desde distintas cuentas. Simulando el uso del contrato por distintos usuarios. Esto es muy importante, ya que para cerrar el crowdfunding necesitamos alcanzar el `STAKE_TARGET`, y para ello necesitamos que distintos usuarios hagan stake.

Los `console.log` son simples mensajes que se muestran en la terminal al ejecutar el test. Nos ayudan a entender qué está pasando en cada momento.

Ahora echemos un vistazo al *exploit* que comentamos anteriormente:

![Screenshot_13](/resources/Screenshot_13.png)

Mediante el *cheatcode* de Foundry `vm.startPrank(attacker)`, indicamos que todas las transacciones que se realicen antes de la instrucción `vm.stopPrank()` se harán siendo `attacker` el `msg.sender`.

Tal y como hemos comentado, el *exploit* consiste en realizar tres stakes, de 100 finney, 100 finney y 57 finney. En el último stake se produce el desbordamiento, consiguiendo que `stakes[attacker] == 1`. Posibilitando la llamada a `closeFund()` y la retirada del 90% de los fondos. Además, podremos llamar a `withdraw()` y retirar el 10% restante ya que también somos el `LeadInvestor`.

Para ejecutar el test escribimos lo siguiente en la terminal: `forge test --match-contract ProofOfConcept -vv`. El flag `-vv` nos permite activar la *verbosidad*, que nos mostrará los `console.log` que hemos añadido al test.

Deberiamos de obtener el siguiente resultado:

![Screenshot_14](/resources/Screenshot_14.png)


#### Remix

Para aquellos que no puedan utilizar Foundry y quieran replicar el *exploit* en Remix, los pasos a seguir serían:

1. Compilar el contrato `Crowdfund.sol` con la versión correcta del compilador.
2. Desplegar el contrato en la red de Remix.
3. Interactuar con el contrato mediante el desplegable de *Deployed Contracts*. Recuerda que necesitarás cambiar de cuentas, que la primera es la del owner y que la unidad con la que trabajamos es el finney.
4. Hacer `stake` desde distintas cuentas para que, tras el *exploit*, se haya alcanzado el `STAKE_TARGET`. (Mínimo hay que *stakear* 743 finney antes del ataque).
5. Realizar el *exploit*.
   1. Hacer un stake de 100 finney.
   2. Hacer un stake de 100 finney.
   3. Hacer un stake de 57 finney.
   4. Llamar a `closeFund()`.
   5. Llamar a `withdraw()`.
   
## Conclusiones

- Hemos estudiado el contrato inteligente.
- Lo hemos analizado en busca de vulnerabilidades, y hemos encontrado una.
- Hemos realizado un ataque para comprobar que la vulnerabilidad es real.

Este es el proceso que sigue un auditor de contratos inteligentes. Interpreta y analiza el contrato en busca de vulnerabilidades, y si encuentra alguna, realiza una prueba de concepto para comprobar que es real.

Espero que hayas disfrutado del taller, y que hayas aprendido algo nuevo. Si tienes cualquier duda o sugerencia, no dudes en abrir un issue en el repositorio.

Para los que querais seguir aprendiendo sobre seguridad en contratos inteligentes, y os haya gustado el enfoque de Capture The Flag de este taller, os recomiendo que echéis un vistazo a los siguientes repositorios:

- [**All things reentrancy!**](https://github.com/jcsec-security/all-things-reentrancy)
  - Este taller os brindará una visión general sobre cómo identificar ejemplos básicos de la amplia familia de errores de reentrada. También elaboraréis pruebas de concepto para cada uno de ellos, tal y como hemos hecho aquí.    
- [**Solidity Security Course**](https://github.com/jcsec-security/solidity-security-course-resources) - Compuesto por:
  - Ejemplos básicos de vulnerabilidades en contratos inteligentes.
  - Ejercicios más avanzados para practicar la identificación de vulnerabilidades.
  - **Failapop**: Un Capture The Flag que, en lugar de seguir el enfoque clásico, se equipara a un protocolo vulnerable del mundo real, completamente funcional. Aunque muchas vulnerabilidades siguen patrones básicos, este entorno te ofrece la oportunidad de imitar la auditoría de un código real, con todas las dificultades que ello conlleva. El objetivo de este desafío es encontrar y explotar las vulnerabilidades presentes en los distintos contratos que forman el protocolo, a modo de ejercicio práctico, simulando una auditoría de un protocolo real. Es el paso intermedio perfecto entre los CTFs tradicionales y el mundo de la auditoría de proyectos blockchain.
- [**Ethernaut**](https://ethernaut.openzeppelin.com/)
- [**Capture The Ether**](https://capturetheether.com/)

¡Nos vemos en el próximo taller!




