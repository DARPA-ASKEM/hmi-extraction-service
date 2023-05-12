#!/bin/bash
DOCKER_BUILDKIT=0

function image_exists() {
    if [ "$(docker images -q hmi-extraction-service 2> /dev/null)" == "" ]; then
        return 1
    else
        return 0
    fi
}

case "$1" in
    build)
        echo "Building Docker image..."
        docker build -t hmi-extraction-service -f docker/Dockerfile .
    ;;

    start)
        if ! image_exists; then
            echo "Image not found. Building Docker image..."
            docker build -t hmi-extraction-service -f docker/Dockerfile .
        fi

        case "$2" in
            dev)
                echo "Starting Docker container in development mode..."
                docker run -d --name hmi-extraction-service -p 5000:5000 --rm -v "$(pwd)/src":/app hmi-extraction-service
                docker logs -f hmi-extraction-service
            ;;

            prod)
                echo "Starting Docker container in production mode..."
                docker run -d --name hmi-extraction-service -p 5000:5000 --rm hmi-extraction-service
            ;;

            *)
                echo "Usage: ./helper.sh start {dev|prod}"
                exit 1
            ;;
        esac
    ;;

    stop)
        echo "Stopping Docker container..."
        docker stop hmi-extraction-service
    ;;

    restart)
        echo "rebuilding service"
        echo "Stopping Docker container..."
        docker stop hmi-extraction-service
        echo "Building Docker image..."
        docker build -t hmi-extraction-service -f docker/Dockerfile .
        echo "Starting Docker container in development mode..."
        docker run -d --name hmi-extraction-service -p 5000:5000 --rm -v "$(pwd)/src":/app hmi-extraction-service
        docker logs -f hmi-extraction-service
    ;;

    logs)
        echo "Showing logs..."
        docker logs -f hmi-extraction-service
    ;;

    *)
        echo "Usage: ./run.sh {build|start|stop|restart|logs}"
        exit 1
    ;;
esac
