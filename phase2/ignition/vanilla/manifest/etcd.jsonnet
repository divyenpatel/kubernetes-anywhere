function(cfg)
  {
    apiVersion: "v1",
    kind: "Pod",
    metadata: {
      name: "etcd-server",
      namespace: "kube-system",
    },
    spec: {
      hostNetwork: true,
      containers: [
        {
          name: "etcd-container",
          image: "gcr.io/google_containers/etcd:3.1.10",
          resources: {
            requests: {
              cpu: "1000m",
              memory: "2G"
            },
          },
          command: [
            "/bin/sh",
            "-c",
            |||
              /usr/local/bin/etcd \
                --listen-peer-urls http://127.0.0.1:2380 \
                --advertise-client-urls http://127.0.0.1:2379 \
                --listen-client-urls http://127.0.0.1:2379 \
                --data-dir /var/etcd/data
            |||,
          ],
          livenessProbe: {
            httpGet: {
              host: "127.0.0.1",
              port: 2379,
              path: "/health",
            },
            initialDelaySeconds: 15,
            timeoutSeconds: 15,
          },
          ports: [
            {
              name: "serverport",
              containerPort: 2380,
              hostPort: 2380,
            },
            {
              name: "clientport",
              containerPort: 2379,
              hostPort: 2379,
            },
          ],
          volumeMounts: [
            {
              name: "varetcd",
              mountPath: "/var/etcd",
              readOnly: false,
            },
          ],
        },
      ],
      volumes: [
        {
          name: "varetcd",
          hostPath: {
            path: "/var/etcd",
          },
        },
      ],
    },
  }
