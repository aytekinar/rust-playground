ARG BASE_IMAGE
ARG BASE_VERSION

FROM ${BASE_IMAGE}:${BASE_VERSION} AS development
ARG DEVEL_DEPS

# Install development dependencies
RUN apt-get update --yes
RUN apt-get install --yes ${DEVEL_DEPS}
RUN apt-get autoremove --yes
RUN apt-get autoclean --yes

# Install clippy and rustfmt
RUN rustup component add clippy rustfmt

# Install flamegraph
RUN cargo install flamegraph

# Create a non-root user with sudo privileges
ARG USER_NAME
ARG USER_ID
ARG USER_SHELL
RUN useradd --create-home --user-group --shell ${USER_SHELL} --uid ${USER_ID} ${USER_NAME}
RUN printf '%s ALL=(ALL:ALL) NOPASSWD:ALL\n' ${USER_NAME} >> /etc/sudoers.d/${USER_NAME}
RUN install --directory --owner=${USER_NAME} --group=${USER_NAME} --mode=700 /home/${USER_NAME}/.ssh
RUN install --directory --owner=${USER_NAME} --group=${USER_NAME} /workspace

# Switch to the non-root user
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
