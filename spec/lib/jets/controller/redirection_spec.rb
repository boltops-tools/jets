# frozen_string_literal: true

class RedirectionController < Jets::Controller::Base
end

describe RedirectionController do
  let(:controller) { RedirectionController.new(event, context, meth) }
  let(:context) { nil }
  let(:meth) { "index" }

  context "localhost" do
    context "rack headers with Host and origin" do
      # the fixture uses actual data capture from a local request
      let(:event) do
        json_file("spec/fixtures/dumps/rack/posts/create.json")
      end
      it "redirect_to" do
        status, headers, body = controller.send(:redirect_to, "/myurl", status: 301)
        expect(status).to eq "301"
        expect(headers["Location"]).to eq "http://localhost:8888/myurl"
      end
    end
  end

  context "amazonaws.com" do
    context "api gateway headers with Host and X-Forwarded-Proto" do
      # the fixture uses actual data capture from a api gateay request
      let(:event) do
        json_file("spec/fixtures/dumps/api_gateway/posts/create.json")
      end
      it "redirect_to adds the stage name to the url" do
        status, headers, body = controller.send(:redirect_to, "/myurl", status: 301)
        expect(status).to eq "301"
        expect(headers["Location"]).to eq "https://8s1wzivnz4.execute-api.us-east-1.amazonaws.com/test/myurl"
      end
    end
  end
end
