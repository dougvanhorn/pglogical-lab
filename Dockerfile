FROM postgres:15-bookworm


RUN apt update && \
    apt install -y \
    postgresql-15-pglogical \
    vim

# Custom configuration.
COPY postgresql.conf /etc/postgresql/postgresql.conf

# Use custom configuration.
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
