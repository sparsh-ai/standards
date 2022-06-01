init:
	pip install --upgrade pip &&\
		pip install -r requirements.txt

test:
	pytest tests

.PHONY: api
api:
	uvicorn app:app --port 5000 --reload
	nohup uvicorn app:app --port 5000 --reload > logs.out 2>&1 &
	kill -9 $(lsof -t -i:5000)
	
.PHONY: docs
docs:
	cd docs && npx docusaurus start

.PHONY: app
app:
	cd app/app && streamlit run app.py --server.port=8080

.PHONY: format
format:
	black $$(git ls-files '*.py')

dvc-init:
	dvc init
	dvc remote add -d storage s3://s3bucket/dvcstore
	dvc config core.autostage true

lint:
	pylint --disable=R,C src

test:
	python -m pytest -vv tests
	python -m pytest -vv --cov=src

parallel-test:
	python -m pytest -n auto --dist loadgroup -vv --cov=mylib tests/ 

profile-test-code:
	python -m pytest -vv --durations=1 --durations-min=1.0

codesync:
	python src/symlink.py
	