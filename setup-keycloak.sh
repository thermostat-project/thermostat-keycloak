#!/bin/bash
#
# Copyright 2012-2017 Red Hat, Inc.
#
# This file is part of Thermostat.
#
# Thermostat is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 2, or (at your
# option) any later version.
#
# Thermostat is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Thermostat; see the file COPYING.  If not see
# <http://www.gnu.org/licenses/>.
#
# Linking this code with other modules is making a combined work
# based on this code.  Thus, the terms and conditions of the GNU
# General Public License cover the whole combination.
#
# As a special exception, the copyright holders of this code give
# you permission to link this code with independent modules to
# produce an executable, regardless of the license terms of these
# independent modules, and to copy and distribute the resulting
# executable under terms of your choice, provided that you also
# meet, for each linked independent module, the terms and conditions
# of the license of that module.  An independent module is a module
# which is not derived from or based on this code.  If you modify
# this code, you may extend this exception to your version of the
# library, but you are not obligated to do so.  If you do not wish
# to do so, delete this exception statement from your version.
#


# Listing of users and their roles
# User : Role
# A : r-a
# B : w-a
# C : u-a
# D : d-a
# E : r-a r-b
# F : w-a u-a d-a
# G : w-a u-a d-a wud-b

KEYCLOAK_ADMIN=tms-admin

TMS_A=tms-a
TMS_B=tms-b
TMS_C=tms-c
TMS_D=tms-d
TMS_E=tms-e
TMS_F=tms-f
TMS_G=tms-g

ROLE_R_A=r-a
ROLE_W_A=w-a
ROLE_U_A=u-a
ROLE_D_A=d-a
ROLE_R_B=r-b
ROLE_WUD_B=w,u,d-b

THERMOSTAT_PASSWORD=tms-pass

KEYCLOAK_REALM=thermostat

SERVER=http://127.0.0.1:8080/auth
CLI=keycloak/bin/kcadm.sh

keycloak/bin/add-user-keycloak.sh --user ${KEYCLOAK_ADMIN} --password ${KEYCLOAK_ADMIN}

keycloak/bin/standalone.sh & >/dev/null 2&>1

# Wait for keycloak to startup
HOST=127.0.0.1
PORT=8080
RETRIES=25

sleep 10
until curl -f -v "http://${HOST}:${PORT}/auth" >/dev/null 2>/dev/null
do
    RETRIES=$(($RETRIES - 1))
    if [ $RETRIES -eq 0 ]
    then
        echo "Failed to connect"
        exit 1
    fi
    sleep 2
done
echo

${CLI} config credentials --server ${SERVER} --realm master --user ${KEYCLOAK_ADMIN} --password ${KEYCLOAK_ADMIN}

${CLI} create realms -s realm=${KEYCLOAK_REALM} -s enabled=true

${CLI} create roles -r ${KEYCLOAK_REALM} -s name=thermostat

${CLI} create roles -r ${KEYCLOAK_REALM} -s name=${ROLE_R_A}
${CLI} create roles -r ${KEYCLOAK_REALM} -s name=${ROLE_W_A}
${CLI} create roles -r ${KEYCLOAK_REALM} -s name=${ROLE_U_A}
${CLI} create roles -r ${KEYCLOAK_REALM} -s name=${ROLE_D_A}
${CLI} create roles -r ${KEYCLOAK_REALM} -s name=${ROLE_R_B}
${CLI} create roles -r ${KEYCLOAK_REALM} -s name=${ROLE_WUD_A}
${CLI} create roles -r ${KEYCLOAK_REALM} -s name=${ROLE_WUD_B}

${CLI} create clients -r ${KEYCLOAK_REALM} -s clientId=thermostat-bearer -s enabled=true -s bearerOnly=true

${CLI} create clients -r ${KEYCLOAK_REALM} -s clientId=thermostat-web-client -s enabled=true -s publicClient=true -s 'redirectUris=["http://localhost:8080/*"]' -s 'webOrigins=["+"]' -s directAccessGrantsEnabled=true

${CLI} create users -r ${KEYCLOAK_REALM} -s enabled=true -s username=${TMS_A}
${CLI} add-roles -r ${KEYCLOAK_REALM} --uusername ${TMS_A} --rolename thermostat --rolename ${ROLE_R_A}
${CLI} set-password -r ${KEYCLOAK_REALM} --username ${TMS_A} --new-password ${THERMOSTAT_PASSWORD}

${CLI} create users -r ${KEYCLOAK_REALM} -s enabled=true -s username=${TMS_B}
${CLI} add-roles -r ${KEYCLOAK_REALM} --uusername ${TMS_B} --rolename thermostat --rolename ${ROLE_W_A}
${CLI} set-password -r ${KEYCLOAK_REALM} --username ${TMS_B} --new-password ${THERMOSTAT_PASSWORD}

${CLI} create users -r ${KEYCLOAK_REALM} -s enabled=true -s username=${TMS_C}
${CLI} add-roles -r ${KEYCLOAK_REALM} --uusername ${TMS_C} --rolename thermostat --rolename ${ROLE_U_A}
${CLI} set-password -r ${KEYCLOAK_REALM} --username ${TMS_C} --new-password ${THERMOSTAT_PASSWORD}

${CLI} create users -r ${KEYCLOAK_REALM} -s enabled=true -s username=${TMS_D}
${CLI} add-roles -r ${KEYCLOAK_REALM} --uusername ${TMS_D} --rolename thermostat --rolename ${ROLE_D_A}
${CLI} set-password -r ${KEYCLOAK_REALM} --username ${TMS_D} --new-password ${THERMOSTAT_PASSWORD}

${CLI} create users -r ${KEYCLOAK_REALM} -s enabled=true -s username=${TMS_E}
${CLI} add-roles -r ${KEYCLOAK_REALM} --uusername ${TMS_E} --rolename thermostat --rolename ${ROLE_R_A} --rolename ${ROLE_R_B}
${CLI} set-password -r ${KEYCLOAK_REALM} --username ${TMS_E} --new-password ${THERMOSTAT_PASSWORD}

${CLI} create users -r ${KEYCLOAK_REALM} -s enabled=true -s username=${TMS_F}
${CLI} add-roles -r ${KEYCLOAK_REALM} --uusername ${TMS_F} --rolename thermostat --rolename ${ROLE_W_A} --rolename ${ROLE_U_A} --rolename ${ROLE_D_A}
${CLI} set-password -r ${KEYCLOAK_REALM} --username ${TMS_F} --new-password ${THERMOSTAT_PASSWORD}

${CLI} create users -r ${KEYCLOAK_REALM} -s enabled=true -s username=${TMS_G}
${CLI} add-roles -r ${KEYCLOAK_REALM} --uusername ${TMS_G} --rolename thermostat --rolename ${ROLE_W_A} --rolename ${ROLE_U_A} --rolename ${ROLE_D_A} --rolename ${ROLE_WUD_B}
${CLI} set-password -r ${KEYCLOAK_REALM} --username ${TMS_G} --new-password ${THERMOSTAT_PASSWORD}

keycloak/bin/jboss-cli.sh --connect command=:shutdown
