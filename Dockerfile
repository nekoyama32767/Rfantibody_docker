FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y software-properties-common && \
    DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get install --no-install-recommends -y python3.10 python3-pip pipx vim make wget git nano

RUN alias "python"="python3.10"

# Make a virtual env that we can safely install into

#RUN python3 -m venv /opt/venv
# Enable venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install poetry

# Set the working directory to the user's home directory
#WORKDIR /home

#RUN ls /home
#RUN bash /home/include/setup.sh
#RUN bash /home/include/download_weights.sh

#RUN pwd
WORKDIR /home
RUN git clone https://github.com/RosettaCommons/RFantibody.git
#RUN ls

WORKDIR /home/RFantibody

#RUN ls


WORKDIR /home/RFantibody/include/dgl
RUN wget https://data.dgl.ai/wheels/torch-2.3/cu118/dgl-2.4.0%2Bcu118-cp310-cp310-manylinux1_x86_64.whl
WORKDIR /home/RFantibody/include/USalign
RUN make -j

WORKDIR /home/RFantibody
RUN poetry install
RUN poetry run pip install biotite

#RUN bash /home/RFantibody/include/setup.sh
#RUN bash /home/RFantibody/include/download_weights.sh
WORKDIR /home/RFantibody/weights
RUN wget https://files.ipd.uw.edu/pub/RFantibody/RFdiffusion_Ab.pt
RUN wget https://files.ipd.uw.edu/pub/RFantibody/ProteinMPNN_v48_noise_0.2.pt
RUN wget https://files.ipd.uw.edu/pub/RFantibody/RF2_ab.pt


WORKDIR /home/RFantibody
RUN cp -r scripts src/rfantibody/
RUN cp scripts/rfdiffusion_inference.py src/rfantibody/rfdiffusion/ 
WORKDIR /home/work_dir

ENTRYPOINT /bin/bash
