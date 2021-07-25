DE debian: buster-slim
MANTENIMIENTO Odoo SA <info@odoo.com>

SHELL [ "/ bin / bash" , "-xo" , "pipefail" , "-c" ]

# Genere la configuración regional C.UTF-8 para postgres y datos de configuración regional general
ENV LANG C.UTF-8

# Instale algunos deps, lessc y less-plugin-clean-css, y wkhtmltopdf
EJECUTAR apt-get update && \
    apt-get install -y --no-install-recomienda \
        certificados de ca \
        rizo \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        sin nodo \
        npm \
        python3-num2words \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-perro guardián \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recomienda ./wkhtmltox.deb \
    && rm -rf / var / lib / apt / lists / * wkhtmltox.deb

# instalar el último cliente de postgresql
EJECUTE echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME = "$ (mktemp -d)" \
    && exportar GNUPGHOME \
    && repokey = 'B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$ {repokey}" \
    && gpg --batch --armor --export "$ {repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$ GNUPGHOME" \
    && apt-get update \
    && apt-get install --no-install-recommended -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf / var / lib / apt / lists / *

# Instalar rtlcss (en Debian buster)
RUN NPM instalar rtlcss -g

# Instalar Odoo
ENV ODOO_VERSION 14.0
ARG ODOO_RELEASE = 20210720
ARG ODOO_SHA = 897a15c05244de02eceac2a930d169f2010971a6
EJECUTE curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
    && echo "$ {ODOO_SHA} odoo.deb" | sha1sum -c - \
    && apt-get update \
    && apt-get -y install --no-install-recomienda ./odoo.deb \
    && rm -rf / var / lib / apt / lists / * odoo.deb

# Copie el script de punto de entrada y el archivo de configuración de Odoo
COPIA ./entrypoint.sh /
COPIA ./odoo.conf / etc / odoo /

# Establezca los permisos y monte / var / lib / odoo para permitir la restauración del almacén de archivos y / mnt / extra-addons para los complementos de los usuarios
RUN chown odoo /etc/odoo/odoo.conf \
    && mkdir -p / mnt / extra-addons \
    && chown -R odoo / mnt / extra-addons
VOLUMEN [ "/ var / lib / odoo" , "/ mnt / extra-addons" ]

# Exponer los servicios de Odoo
EXPONER 8069 8071 8072

# Establecer el archivo de configuración predeterminado
ENV ODOO_RC /etc/odoo/odoo.conf

COPIA wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Establecer usuario predeterminado al ejecutar el contenedor
USUARIO odoo

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "odoo" ]
