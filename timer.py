import time


class Timer:
    def __init__(self, label="Execution time", logger=None):
        self.label = label
        self.logger = logger

    def __call__(self, func):
        def wrapped_func(*args, **kwargs):
            start_time = time.time()
            # before
            result = func(*args, **kwargs)
            # after
            end_time = time.time()
            duration = end_time - start_time
            minutes, seconds = divmod(duration, 60)
            str_temps = f"{seconds:.1f}s" if minutes == 0 else f"{int(minutes)} min {int(seconds)}s"
            name = f" - {kwargs['name']}" if "name" in kwargs else ""

            if self.logger:
                self.logger.info(f"{self.label} ({str_temps}){name}")
            else:
                print(f"{self.label} ({str_temps}){name}")

            return result

        return wrapped_func


# Exemple d'utilisation
if __name__ == "__main__":
    # Exemple d'utilisation
    @Timer(label="Téléchargement réussi")
    def my_func():
        # Simuler une tâche longue
        time.sleep(2)
        print("Fonction exécutée")

    my_func()
