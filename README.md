# 2 ASIR - DHCP - Practice A (Client/Server)

## Authors of the project

- **Juan Amador Hinojosa Gálvez** `jhingal3010@ieszaidinvergeles.org`
- **Álvaro Rodríguez Pulido** `arodpul3005@ieszaidinvergeles.org`

## Practice Objective

Set up a virtualized environment with three virtual machines:

- **DHCP Server (sv)** that assigns network configurations automatically.
- **Client 1 (c1)** that receives its network configuration via DHCP.
- **Client 2 (c2)** that gets a fixed IP address based on its MAC address.

---

## Network Structure

- External (host-only) network: `192.168.56.0/24`
  - **Server**: static IP `192.168.56.10`
- Internal network: `192.168.57.0/24`
  - **Server**: static IP `192.168.57.10`
  - **c1** and **c2**: DHCP clients

---

## Prerequisites

- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/)
- Recommended base box: `ubuntu/jammy64`

---

## Project Initialization

Initialize the project with the command:

```bash
vagrant init
