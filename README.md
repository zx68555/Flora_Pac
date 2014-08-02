# Flora PAC

A PAC(Proxy auto-config) file generator with fetched China IP range, which helps walk around GFW.

Inspired by https://github.com/fivesheep/chnroutes .

## Installation
<pre>
$ git clone https://github.com/usufu/Flora_Pac.git
</pre>

## Uasge
<pre>
$ ./flora_pac -h
usage: flora_pac [-h] [-x [PROXY]] [-p [PORT]] [-i [PROXY]]

Generate proxy auto-config rules.

optional arguments:
  -h, --help            show this help message and exit
  -x [PROXY], --proxy [PROXY]
                        Proxy Server, examples:
                            SOCKS5 127.0.0.1:8964;
                            SOCKS 127.0.0.1:8964;
                            PROXY 127.0.0.1:6489
  -i [PROXY], --iproxy [PROXY]
                        internal Proxy server, default is DIRECT, especially for company network if it need a internal proxy to access outside network.
  -p [PORT], --port [PORT]
                        Pac Server Port [OPTIONAL], examples: 8970
</pre>
* Run as a HTTP PAC server:
<pre>
$ ./flora_pac -x 'SOCKS5 127.0.0.1:8964; SOCKS 127.0.0.1:8964; DIRECT' -p 8970
</pre>
* Use test_build.sh to generate a pac file, replace the proxy address in the script before you launch it.
<pre>
$./test_buils.sh
</pre>
flora_pac.pac and flora_pac_min.pac will be generated, floar_pac_min.pac is samller than the flora_pac.pac, but hard for reading.
you can edit the flora.pac to add safeDomain and dangerDomain.

![PAC Server demo on Mac](https://raw.github.com/Leask/Flora_Pac/master/screenshots/mac.jpg "PAC Server demo on Mac")

## Get help
* twitter: @cnpipe